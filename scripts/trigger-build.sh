#!/bin/bash
# ============================================================
# TRIGGER BUILD — Start a pipeline build and watch it
# ============================================================

set -e

JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_PASS="admin123"
JOB_NAME="expense-tracker-pipeline"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}🚀 Triggering pipeline build...${NC}"
echo ""

# Get crumb + session cookie
CRUMB_RESPONSE=$(curl -s -c /tmp/jenkins-cookies.txt \
    -u "$JENKINS_USER:$JENKINS_PASS" \
    "$JENKINS_URL/crumbIssuer/api/json")
CRUMB=$(echo "$CRUMB_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['crumb'])" 2>/dev/null)
CRUMB_FIELD=$(echo "$CRUMB_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['crumbRequestField'])" 2>/dev/null)

# Trigger build
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -b /tmp/jenkins-cookies.txt \
    -u "$JENKINS_USER:$JENKINS_PASS" \
    -H "$CRUMB_FIELD:$CRUMB" \
    -X POST \
    "$JENKINS_URL/job/$JOB_NAME/build")

if [ "$HTTP_CODE" = "201" ]; then
    echo -e "${GREEN}✅ Build triggered!${NC}"
else
    echo -e "${RED}❌ Failed to trigger build (HTTP $HTTP_CODE)${NC}"
    rm -f /tmp/jenkins-cookies.txt
    exit 1
fi

echo ""
echo -e "  ${BOLD}Watch the build:${NC}"
echo -e "    Browser:  ${CYAN}http://localhost:8080/job/$JOB_NAME/${NC}"
echo -e "    Blue Ocean: ${CYAN}http://localhost:8080/blue/organizations/jenkins/$JOB_NAME/activity${NC}"
echo ""

# Wait a moment for the build to start
sleep 3

# Poll for build status
echo -e "  ${BOLD}Build progress:${NC}"
BUILD_NUM=""
for i in $(seq 1 5); do
    BUILD_NUM=$(curl -s -u "$JENKINS_USER:$JENKINS_PASS" \
        "$JENKINS_URL/job/$JOB_NAME/lastBuild/buildNumber" 2>/dev/null)
    if [ -n "$BUILD_NUM" ] && [ "$BUILD_NUM" != "" ]; then
        break
    fi
    sleep 2
done

if [ -z "$BUILD_NUM" ]; then
    echo -e "    Build is queued. Check the browser for progress."
    rm -f /tmp/jenkins-cookies.txt
    exit 0
fi

echo -e "    Build #${BUILD_NUM} started"
echo ""

# Poll until complete
while true; do
    BUILD_INFO=$(curl -s -u "$JENKINS_USER:$JENKINS_PASS" \
        "$JENKINS_URL/job/$JOB_NAME/$BUILD_NUM/api/json?tree=result,building,displayName,duration" 2>/dev/null)
    
    BUILDING=$(echo "$BUILD_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin).get('building', True))" 2>/dev/null)
    RESULT=$(echo "$BUILD_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin).get('result', 'N/A'))" 2>/dev/null)
    
    if [ "$BUILDING" = "False" ]; then
        echo ""
        if [ "$RESULT" = "SUCCESS" ]; then
            echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║   ✅ BUILD #$BUILD_NUM SUCCEEDED!           ║${NC}"
            echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
        elif [ "$RESULT" = "FAILURE" ]; then
            echo -e "${RED}╔══════════════════════════════════════╗${NC}"
            echo -e "${RED}║   ❌ BUILD #$BUILD_NUM FAILED!               ║${NC}"
            echo -e "${RED}╚══════════════════════════════════════╝${NC}"
        else
            echo -e "${YELLOW}  Build #$BUILD_NUM finished with result: $RESULT${NC}"
        fi
        echo ""
        echo -e "  Console log: ${CYAN}http://localhost:8080/job/$JOB_NAME/$BUILD_NUM/console${NC}"
        echo -e "  SonarQube:   ${CYAN}http://localhost:9000/dashboard?id=expense-tracker${NC}"
        break
    fi
    
    # Show current stage
    STAGE_INFO=$(curl -s -u "$JENKINS_USER:$JENKINS_PASS" \
        "$JENKINS_URL/job/$JOB_NAME/$BUILD_NUM/wfapi/describe" 2>/dev/null)
    CURRENT_STAGE=$(echo "$STAGE_INFO" | python3 -c "
import sys, json
data = json.load(sys.stdin)
stages = data.get('stages', [])
for s in stages:
    if s.get('status') == 'IN_PROGRESS':
        print(s.get('name', '?'))
        break
else:
    running = [s['name'] for s in stages if s.get('status') not in ('SUCCESS','FAILED','NOT_EXECUTED')]
    print(running[0] if running else 'waiting...')
" 2>/dev/null || echo "loading...")
    
    echo -e "    ⏳ Stage: ${CYAN}${CURRENT_STAGE}${NC}"
    sleep 5
done

rm -f /tmp/jenkins-cookies.txt
