# Step 5: SonarQube Integration

> SonarQube is like a teacher grading your code. Let's connect it to Jenkins.

---

## What is SonarQube?

**Simple**: SonarQube reads all your code and tells you what's bad.

**Real talk**: SonarQube performs static code analysis. It checks for:
- **Bugs** — Code that will break
- **Vulnerabilities** — Security holes
- **Code Smells** — Code that works but is messy
- **Duplications** — Copy-pasted code
- **Coverage** — How much of your code is tested

---

## First Time SonarQube Setup

### 1. Open SonarQube
- Go to **http://localhost:9000**
- Login: `admin` / `admin`
- It will force you to change the password
- New password: `sonarqube` (or whatever you want — it's local)

### 2. Create a Project
- Click **"Create project manually"**
- Project display name: `expense-tracker`
- Project key: `expense-tracker`
- Main branch name: `main`
- Click **"Next"**
- Choose **"Use the global setting"** for New Code definition
- Click **"Create Project"**

### 3. Generate a Token
- Go to your SonarQube project
- Click **"Locally"** (analysis method)
- Generate a token:
  - Name: `jenkins-token`
  - Type: **Project Analysis Token**
  - Expires in: No expiration
- Click **"Generate"**
- **COPY THIS TOKEN** — you'll need it for Jenkins!
  - It looks like: `sqp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### 4. Add Token to Jenkins
Back in Jenkins (http://localhost:8080):

1. Go to **Manage Jenkins → Credentials → System → Global credentials**
2. Click **"Add Credentials"**
3. Fill in:
   - Kind: **Secret text**
   - Secret: Paste your SonarQube token
   - ID: `sonarqube-token`
   - Description: `SonarQube Analysis Token`
4. Click **"Create"**

### 5. Configure SonarQube in Jenkins
1. Go to **Manage Jenkins → System**
2. Scroll to **SonarQube servers**
3. Check **"Environment variables"**
4. Click **"Add SonarQube"**:
   - Name: `SonarQube`
   - Server URL: `http://sonarqube:9000`
   - Server authentication token: Choose `sonarqube-token` from dropdown
5. Click **"Save"**

### 6. Configure SonarQube Scanner Tool
1. Go to **Manage Jenkins → Tools**
2. Scroll to **SonarQube Scanner installations**
3. Click **"Add SonarQube Scanner"**:
   - Name: `SonarScanner`
   - Install automatically: ✅ checked
   - Version: Latest
4. Click **"Save"**

---

## How SonarQube Works in the Pipeline

```
Your Code
    │
    ▼
┌─────────────────────────────┐
│ SonarQube Scanner            │
│ (runs in Jenkins)            │
│                              │
│ Reads every .ts, .tsx file   │
│ Checks 500+ rules            │
│ Generates a report           │
│ Sends report to SonarQube    │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ SonarQube Server             │
│ (http://localhost:9000)      │
│                              │
│ Stores the report            │
│ Shows dashboard              │
│ Applies Quality Gate         │
│                              │
│ Quality Gate = PASS or FAIL  │
└─────────────────────────────┘
```

---

## The Quality Gate

A **Quality Gate** is a set of rules. If your code doesn't meet them, the gate FAILS and the pipeline stops.

### Default Quality Gate Rules:
| Metric | Threshold | Meaning |
|--------|-----------|---------|
| New Bugs | 0 | No new bugs allowed |
| New Vulnerabilities | 0 | No new security holes |
| New Code Smells | A rating | Must maintain "A" rating |
| Coverage on New Code | 80% | At least 80% of new code must be tested |
| Duplication on New Code | < 3% | Less than 3% copy-paste |

Think of the Quality Gate as the **bouncer at a club** — if your code doesn't look good enough, it doesn't get in.

---

## The sonar-project.properties File

This file tells the scanner what to scan and where. It's already in your project root:

```properties
sonar.projectKey=expense-tracker
sonar.projectName=Expense Tracker
sonar.sources=src
sonar.tests=__tests__
sonar.exclusions=**/*.test.ts,**/*.test.tsx,**/*.spec.ts
sonar.typescript.lcov.reportPaths=coverage/lcov.info
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

### What each line means:
| Property | Meaning |
|----------|---------|
| `projectKey` | Unique ID (must match SonarQube project) |
| `sources` | Which folders to scan |
| `tests` | Where test files live |
| `exclusions` | Skip these files from analysis |
| `lcov.reportPaths` | Where test coverage data is |

---

## Jenkinsfile Stages for SonarQube

The Jenkinsfile already includes these stages:

```groovy
stage('Test') {
    steps {
        // Run tests WITH coverage (SonarQube needs this)
        sh 'npm run test:coverage'
    }
}

stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('SonarQube') {
            sh "${tool('SonarScanner')}/bin/sonar-scanner"
        }
    }
}

stage('Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
```

### What happens:
1. **Test stage** runs tests and generates `coverage/lcov.info`
2. **SonarQube Analysis** sends code + coverage to SonarQube
3. **Quality Gate** waits for SonarQube's verdict — PASS or FAIL

If Quality Gate fails → **pipeline stops** → code doesn't get deployed.

---

## View Your Report

After the pipeline runs with SonarQube:

1. Go to **http://localhost:9000**
2. Click on your **expense-tracker** project
3. Explore:
   - **Overview**: Summary of code health
   - **Issues**: Every problem found, sorted by severity
   - **Measures**: Detailed metrics (coverage, duplications, etc.)
   - **Code**: Click into any file to see issues inline

---

## Practice Exercises

### Exercise 1: Break the Quality Gate on Purpose
1. Add a `console.log` in your code (SonarQube flags this as a code smell)
2. Push the code
3. Watch the pipeline — the Quality Gate should fail!
4. Fix it and push again

### Exercise 2: Improve Coverage
1. Check your coverage percentage in SonarQube
2. Find a file with low coverage
3. Write a test for it
4. Push and watch the coverage improve

---

## Checkpoint ✅

Before moving on, verify:
- [ ] SonarQube is running at http://localhost:9000
- [ ] SonarQube project "expense-tracker" exists
- [ ] Jenkins is connected to SonarQube (token configured)
- [ ] Pipeline runs SonarQube analysis stage
- [ ] Quality Gate passes (or fails and you understand why)
- [ ] You can see the report at http://localhost:9000

---

## Next Step
👉 Go to [06-security-scanning.md](06-security-scanning.md) to add security scans
