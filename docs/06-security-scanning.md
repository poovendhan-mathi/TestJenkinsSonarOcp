# Step 6: Security Scanning (Trivy + OWASP)

> Security scanning finds vulnerable packages in your project. Like a health inspection for code.

---

## Why Security Scanning?

Remember the **Log4j disaster** in 2021? One tiny vulnerable library brought down half the internet. Security scanners catch these **before** your code goes live.

**Simple**: You use 1000+ packages (open-source libraries). Some might have known security holes. Scanners check all of them against a database of known problems.

---

## Tool 1: Trivy (Our Main Scanner)

### What is Trivy?
- Free, open-source security scanner by Aqua Security
- Scans: dependencies, containers, config files
- Used by: Apple, Microsoft, Amazon, and many more
- Replaces the paid JFrog Xray tool

### What Trivy Checks:
| Scan Type | What It Finds | When We Use It |
|-----------|--------------|----------------|
| **Filesystem** (`trivy fs`) | Vulnerable npm packages | Every pipeline run |
| **Container** (`trivy image`) | Vulnerable OS packages in Docker image | After Docker build |
| **Config** (`trivy config`) | Misconfigurations in Dockerfile, K8s YAML | Before deployment |

### Try It Yourself (Terminal):
```bash
cd /Volumes/POOVENDHAN/DOCUMENTS/TestJenkinsSonarOcp

# Scan your project for vulnerable npm packages
trivy fs --severity HIGH,CRITICAL .

# What the output means:
# CRITICAL = Red alert! Fix immediately!
# HIGH     = Serious. Fix soon.
# MEDIUM   = Should fix when possible.
# LOW      = Nice to fix, not urgent.
```

### Understanding Trivy Output:
```
package-name (npm)
====================
Total: 2 (HIGH: 1, CRITICAL: 1)

┌────────────────┬──────────┬──────────┬─────────────┬─────────┐
│    Library     │ Severity │ Vuln ID  │  Installed  │  Fixed  │
├────────────────┼──────────┼──────────┼─────────────┼─────────┤
│ lodash         │ CRITICAL │ CVE-XXXX │ 4.17.11     │ 4.17.21 │
│ axios          │ HIGH     │ CVE-YYYY │ 0.21.0      │ 0.21.1  │
└────────────────┴──────────┴──────────┴─────────────┴─────────┘
```

**How to read it**: "lodash version 4.17.11 has a CRITICAL vulnerability. Update to 4.17.21 to fix it."

---

## Tool 2: OWASP Dependency-Check

### What is OWASP?
- OWASP = Open Web Application Security Project (non-profit)
- Dependency-Check scans your npm packages against the **NVD** (National Vulnerability Database)
- It's like Trivy but focuses specifically on package dependencies

### Why Use Both?
Different scanners catch different things. In big companies, they run **multiple scanners** for maximum coverage:

```
Trivy      → Fast, broad coverage (deps + containers + config)
OWASP DC   → Deep dependency analysis (NVD database)
Together   → More comprehensive than either alone
```

### In the Pipeline:
OWASP runs as a Docker container (no install needed):
```groovy
stage('OWASP Dependency Check') {
    steps {
        sh '''
            docker run --rm \
                -v $(pwd):/src \
                -v owasp-data:/usr/share/dependency-check/data \
                owasp/dependency-check:latest \
                --project "Expense Tracker" \
                --scan /src \
                --format HTML \
                --format JSON \
                --out /src/reports
        '''
    }
}
```

---

## How They Fit in the Pipeline

```
                    ┌─────────────────┐
  After Build +     │ SECURITY SCANS  │
  Test pass:        │  (parallel)     │
                    │                 │
                    │ ┌─────────────┐ │
                    │ │ Trivy FS    │ │ ← Scan npm packages
                    │ │ Scan        │ │
                    │ └─────────────┘ │
                    │                 │
                    │ ┌─────────────┐ │
                    │ │ OWASP       │ │ ← Deep dependency check
                    │ │ Dep-Check   │ │
                    │ └─────────────┘ │
                    │                 │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Any CRITICAL?   │
                    │                 │
                    │ YES → ❌ FAIL    │
                    │ NO  → ✅ PASS    │
                    └─────────────────┘
```

They run **in parallel** (at the same time) to save time.

---

## Jenkinsfile Security Stages

Already configured in your Jenkinsfile:

```groovy
stage('Security Scans') {
    parallel {
        stage('Trivy Scan') {
            steps {
                sh 'trivy fs --severity HIGH,CRITICAL --exit-code 1 --format table .'
            }
        }
        stage('OWASP Dependency Check') {
            steps {
                sh '''
                    docker run --rm \
                        -v $(pwd):/src \
                        -v owasp-data:/usr/share/dependency-check/data \
                        owasp/dependency-check:latest \
                        --project "Expense Tracker" \
                        --scan /src \
                        --format HTML --out /src/reports \
                        --failOnCVSS 9
                '''
                publishHTML([
                    reportDir: 'reports',
                    reportFiles: 'dependency-check-report.html',
                    reportName: 'OWASP Dependency Check'
                ])
            }
        }
    }
}
```

### Key flags:
| Flag | Meaning |
|------|---------|
| `--exit-code 1` | Trivy returns error code 1 if vulnerabilities found → pipeline fails |
| `--severity HIGH,CRITICAL` | Only care about serious stuff |
| `--failOnCVSS 9` | OWASP fails if CVSS score ≥ 9 (CRITICAL) |

---

## What If Vulnerabilities Are Found?

### Option 1: Fix It (Best)
```bash
# See what's vulnerable
npm audit

# Auto-fix what's possible
npm audit fix

# If that doesn't work, manually update
npm install package-name@latest
```

### Option 2: Suppress It (When You Can't Fix It)
Sometimes a vulnerability exists but doesn't affect your code. You can suppress it:

Create `.trivyignore` in project root:
```
# Suppress specific CVEs with a comment explaining why
# CVE-2024-XXXXX: Not applicable - we don't use the affected function
CVE-2024-XXXXX
```

### Option 3: Accept Risk (Last Resort)
In the Jenkinsfile, change `--exit-code 1` to `--exit-code 0` to not fail the pipeline. **Only do this temporarily** with a plan to fix.

---

## Xray vs Trivy (Why We Chose Trivy)

| Feature | JFrog Xray | Trivy |
|---------|-----------|-------|
| **Cost** | $$$$ (Enterprise) | FREE |
| **npm scanning** | ✅ | ✅ |
| **Container scanning** | ✅ | ✅ |
| **IaC scanning** | ✅ | ✅ |
| **License compliance** | ✅ | ✅ |
| **Setup** | Complex (needs Artifactory) | 1 command (`brew install trivy`) |
| **Used by** | Large enterprises | Everyone (including large enterprises) |

**Bottom line**: Trivy does 90% of what Xray does, for free.

---

## Practice Exercises

### Exercise 1: Run Your First Scan
```bash
cd /Volumes/POOVENDHAN/DOCUMENTS/TestJenkinsSonarOcp
trivy fs .
```
Read the output. How many vulnerabilities did it find?

### Exercise 2: Intentionally Add a Vulnerable Package
```bash
# Install an OLD version of a package with known vulnerabilities
npm install lodash@4.17.11

# Scan again
trivy fs --severity HIGH,CRITICAL .

# You should see the vulnerability!
# Then fix it:
npm install lodash@latest
```

### Exercise 3: Scan a Docker Image
```bash
# After you build your Docker image (Phase 5):
docker build -t expense-tracker .
trivy image expense-tracker
```

---

## Checkpoint ✅

Before moving on, verify:
- [ ] `trivy fs .` runs and shows results
- [ ] You understand the severity levels (CRITICAL > HIGH > MEDIUM > LOW)
- [ ] Pipeline runs security scans in parallel
- [ ] Pipeline fails when CRITICAL vulnerabilities are found
- [ ] You can read and understand a scan report

---

## Next Step
👉 Go to [07-deploy-to-vercel.md](07-deploy-to-vercel.md) to deploy your app!
