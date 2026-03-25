#!/bin/bash
# ============================================================
# CONFIGURE JENKINS — Automated tool/credential/job setup
# ============================================================
# Configures Jenkins via REST API:
#   1. NodeJS-20 tool
#   2. SonarQube server connection
#   3. SonarScanner tool
#   4. SonarQube token credential
#   5. Pipeline job
# ============================================================

set -e

JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_PASS="admin123"
SONAR_TOKEN="$1"  # Pass SonarQube token as first argument
GITHUB_REPO="https://github.com/poovendhan-mathi/TestJenkinsSonarOcp.git"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

if [ -z "$SONAR_TOKEN" ]; then
    echo -e "${RED}Usage: $0 <sonarqube-token>${NC}"
    echo "  Example: $0 squ_abc123..."
    exit 1
fi

echo ""
echo -e "${BOLD}⚙️  Configuring Jenkins...${NC}"
echo ""

# Get crumb + session cookie
CRUMB_RESPONSE=$(curl -s -c /tmp/jenkins-cookies.txt \
    -u "$JENKINS_USER:$JENKINS_PASS" \
    "$JENKINS_URL/crumbIssuer/api/json")
CRUMB=$(echo "$CRUMB_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['crumb'])" 2>/dev/null)
CRUMB_FIELD=$(echo "$CRUMB_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['crumbRequestField'])" 2>/dev/null)

if [ -z "$CRUMB" ]; then
    echo -e "${RED}❌ Failed to get Jenkins crumb. Is Jenkins running?${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Got Jenkins CSRF token${NC}"

# Helper function to run Groovy on Jenkins
run_groovy() {
    local script="$1"
    local result
    result=$(curl -s -b /tmp/jenkins-cookies.txt \
        -u "$JENKINS_USER:$JENKINS_PASS" \
        -H "$CRUMB_FIELD:$CRUMB" \
        --data-urlencode "script=$script" \
        "$JENKINS_URL/scriptText" 2>&1)
    echo "$result"
}

# ── Step 1: Configure NodeJS-20 tool ──
echo -n "  Configuring NodeJS-20 tool... "
RESULT=$(run_groovy '
import jenkins.plugins.nodejs.tools.*
import hudson.tools.*

def desc = jenkins.model.Jenkins.instance.getDescriptorByType(NodeJSInstallation.DescriptorImpl.class)
def installer = new NodeJSInstaller("20.19.0", "", 100)
def prop = new InstallSourceProperty([installer])
def installation = new NodeJSInstallation("NodeJS-20", "", [prop])
desc.setInstallations(installation)
desc.save()
println("OK")
')
if echo "$RESULT" | grep -q "OK"; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌ $RESULT${NC}"
fi

# ── Step 2: Add SonarQube token as Jenkins credential ──
echo -n "  Adding SonarQube token credential... "
RESULT=$(run_groovy "
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import org.jenkinsci.plugins.plaincredentials.impl.*
import hudson.util.Secret

def store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()
def domain = Domain.global()

// Remove existing if any
def existing = com.cloudbees.plugins.credentials.CredentialsProvider.lookupCredentials(
    com.cloudbees.plugins.credentials.Credentials.class,
    Jenkins.instance, null, null
).find { it.id == 'sonarqube-token' }
if (existing) { store.removeCredentials(domain, existing) }

def secret = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    'sonarqube-token',
    'SonarQube Token for Jenkins',
    Secret.fromString('$SONAR_TOKEN')
)
store.addCredentials(domain, secret)
println('OK')
")
if echo "$RESULT" | grep -q "OK"; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌ $RESULT${NC}"
fi

# ── Step 3: Configure SonarQube server ──
echo -n "  Configuring SonarQube server connection... "
RESULT=$(run_groovy '
import hudson.plugins.sonar.*
import hudson.plugins.sonar.model.*

def instance = jenkins.model.Jenkins.instance
def sonarDesc = instance.getDescriptorByType(SonarGlobalConfiguration.class)

def triggers = new TriggersConfig()
def sonarInst = new SonarInstallation(
    "SonarQube-Local",        // name (matches Jenkinsfile withSonarQubeEnv)
    "http://sonarqube:9000",  // serverUrl (Docker network name!)
    "",                        // serverAuthenticationToken (deprecated)
    "",                        // mojoVersion
    "",                        // additionalAnalysisProperties
    triggers,                  // triggers
    ""                         // additionalProperties
)

// Set credentialsId via reflection (the 7-param constructor does not set it)
def field = sonarInst.class.superclass.getDeclaredField("credentialsId")
field.accessible = true
field.set(sonarInst, "sonarqube-token")

sonarDesc.setInstallations(sonarInst)
sonarDesc.save()
println("OK")
')
if echo "$RESULT" | grep -q "OK"; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌ $RESULT${NC}"
fi

# ── Step 4: Configure SonarScanner tool ──
echo -n "  Configuring SonarScanner tool... "
RESULT=$(run_groovy '
import hudson.plugins.sonar.*
import hudson.tools.*

def desc = jenkins.model.Jenkins.instance.getDescriptorByType(SonarRunnerInstallation.DescriptorImpl.class)
def installer = new SonarRunnerInstaller("5.0.1.3006")
def prop = new InstallSourceProperty([installer])
def installation = new SonarRunnerInstallation("SonarScanner", "", [prop])
desc.setInstallations(installation)
desc.save()
println("OK")
')
if echo "$RESULT" | grep -q "OK"; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌ $RESULT${NC}"
fi

# ── Step 5: Create pipeline job ──
echo -n "  Creating pipeline job... "

# Check if job exists
JOB_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
    -b /tmp/jenkins-cookies.txt \
    -u "$JENKINS_USER:$JENKINS_PASS" \
    "$JENKINS_URL/job/expense-tracker-pipeline/api/json")

JOB_XML="<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin=\"workflow-job\">
  <description>Expense Tracker CI/CD Pipeline - Local Testing</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class=\"org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition\" plugin=\"workflow-cps\">
    <scm class=\"hudson.plugins.git.GitSCM\" plugin=\"git\">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>$GITHUB_REPO</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
    </scm>
    <scriptPath>Jenkinsfile.local</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>"

if [ "$JOB_EXISTS" = "200" ]; then
    # Update existing job
    curl -s -o /dev/null -w "%{http_code}" \
        -b /tmp/jenkins-cookies.txt \
        -u "$JENKINS_USER:$JENKINS_PASS" \
        -H "$CRUMB_FIELD:$CRUMB" \
        -H "Content-Type: application/xml" \
        -d "$JOB_XML" \
        "$JENKINS_URL/job/expense-tracker-pipeline/config.xml" > /dev/null
    echo -e "${GREEN}✅ (updated)${NC}"
else
    # Create new job
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        -b /tmp/jenkins-cookies.txt \
        -u "$JENKINS_USER:$JENKINS_PASS" \
        -H "$CRUMB_FIELD:$CRUMB" \
        -H "Content-Type: application/xml" \
        -d "$JOB_XML" \
        "$JENKINS_URL/createItem?name=expense-tracker-pipeline")
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌ HTTP $HTTP_CODE${NC}"
    fi
fi

# Cleanup
rm -f /tmp/jenkins-cookies.txt

# ── Summary ──
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  ⚙️  Jenkins Configuration Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}What was configured:${NC}"
echo -e "    ✅ NodeJS-20 tool (auto-installs Node.js 20.19.0)"
echo -e "    ✅ SonarQube server → http://sonarqube:9000"
echo -e "    ✅ SonarScanner tool (auto-installs v5.0.1)"
echo -e "    ✅ SonarQube token credential"
echo -e "    ✅ Pipeline job → expense-tracker-pipeline"
echo ""
echo -e "  ${BOLD}Pipeline job details:${NC}"
echo -e "    GitHub repo:  ${CYAN}$GITHUB_REPO${NC}"
echo -e "    Branch:       ${CYAN}main${NC}"
echo -e "    Jenkinsfile:  ${CYAN}Jenkinsfile.local${NC}"
echo ""
echo -e "  ${BOLD}Next: Trigger the build!${NC}"
echo -e "    Option 1 (browser):  Open ${CYAN}http://localhost:8080/job/expense-tracker-pipeline/${NC}"
echo -e "                         Click ${YELLOW}'Build Now'${NC}"
echo ""
echo -e "    Option 2 (terminal): ${CYAN}./scripts/trigger-build.sh${NC}"
echo ""
