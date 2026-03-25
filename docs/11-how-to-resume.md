# How to Resume — Pick Up Where You Left Off

## What's Already Done ✅

| Step | Status |
|------|--------|
| Next.js Expense Tracker app | ✅ Complete |
| All tests passing (11 tests) | ✅ Complete |
| Docker Compose (Jenkins + SonarQube + PostgreSQL) | ✅ Complete |
| Code pushed to GitHub | ✅ Complete |
| SonarQube project + token + webhook | ✅ Configured |
| Jenkins pipeline job (`expense-tracker-pipeline`) | ✅ Created |
| Full pipeline run (Build #4) | ✅ All 10 stages passed |
| Scripts: setup, teardown, configure-jenkins, trigger-build | ✅ Created |

## What's Next (Not Done Yet)

1. **Vercel deployment** — deploy to Vercel (free tier)
2. **Docker Hub** — build & push Docker image
3. **Red Hat Developer Sandbox** — deploy to OpenShift
4. **Full Jenkinsfile** — enable the Docker + OpenShift stages
5. **Webhook** — auto-trigger Jenkins on `git push`

---

## Resume Steps (Copy-Paste Ready)

### Step 1: Start the Environment

```bash
cd /Volumes/POOVENDHAN/DOCUMENTS/TestJenkinsSonarOcp
./scripts/setup.sh
```

This will:
- Build the custom Jenkins Docker image
- Start Jenkins (port 8080), SonarQube (port 9000), PostgreSQL
- Wait until all services are healthy

### Step 2: Configure Jenkins (One-Time After Restart)

Docker volumes preserve data, so Jenkins remembers credentials and jobs.
But if the SonarQube server connection loses its credential binding, run:

```bash
./scripts/configure-jenkins.sh squ_ace66e3a638670b72690f829066895eb477eeffb
```

### Step 3: Trigger a Build

**Option A — Browser:**
1. Open http://localhost:8080
2. Login: `admin` / `admin123`
3. Click `expense-tracker-pipeline` → `Build Now`

**Option B — Terminal:**
```bash
./scripts/trigger-build.sh
```

**Option C — Manual API trigger:**
```bash
# Get CSRF token
CRUMB_RESP=$(curl -s -c /tmp/jk.txt -u admin:admin123 \
  'http://localhost:8080/crumbIssuer/api/json')
CRUMB=$(echo "$CRUMB_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['crumb'])")
FIELD=$(echo "$CRUMB_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['crumbRequestField'])")

# Trigger build
curl -s -o /dev/null -w "%{http_code}" \
  -b /tmp/jk.txt -u admin:admin123 \
  -H "$FIELD:$CRUMB" -X POST \
  'http://localhost:8080/job/expense-tracker-pipeline/build'
```

### Step 4: View Results

| What | URL |
|------|-----|
| Jenkins pipeline | http://localhost:8080/job/expense-tracker-pipeline/ |
| Jenkins Blue Ocean | http://localhost:8080/blue/organizations/jenkins/expense-tracker-pipeline/activity |
| SonarQube dashboard | http://localhost:9000/dashboard?id=expense-tracker |
| Jenkins console log | http://localhost:8080/job/expense-tracker-pipeline/lastBuild/console |

### Step 5: Stop Everything

```bash
./scripts/teardown.sh        # Stop containers (keeps data)
./scripts/teardown.sh --full # Stop + DELETE all data
```

---

## Key Credentials

| Service | Username | Password |
|---------|----------|----------|
| Jenkins | admin | admin123 |
| SonarQube | admin | admin123 |
| SonarQube Token | — | `squ_ace66e3a638670b72690f829066895eb477eeffb` |

## GitHub Repo

```
https://github.com/poovendhan-mathi/TestJenkinsSonarOcp.git
```

Branch: `main` (6 commits)

## Pipeline Stages (What Runs)

```
1. Checkout      → Pull code from GitHub
2. Install       → npm ci
3. Lint          → ESLint checks
4. Build         → Next.js production build
5. Test          → Jest (11 tests, JUnit XML report)
6. SonarQube     → Code quality + bug detection
7. Quality Gate  → Pass/fail based on SonarQube rules
8. Trivy Scan    → Security vulnerability scanner
```

## File Map (Key Files)

```
Jenkinsfile.local          → Pipeline used by Jenkins (8 stages)
Jenkinsfile                → Full pipeline (includes Docker + OpenShift — for later)
docker-compose.yml         → Jenkins + SonarQube + PostgreSQL
jenkins/Dockerfile         → Custom Jenkins image (with Trivy + plugins)
jenkins/plugins.txt        → Pre-installed Jenkins plugins
sonar-project.properties   → SonarQube scanner config
scripts/setup.sh           → Start everything
scripts/teardown.sh        → Stop everything
scripts/configure-jenkins.sh → Auto-configure Jenkins tools + jobs
scripts/trigger-build.sh   → Trigger build from terminal
```

## Troubleshooting

**"Not authorized" in SonarQube stage?**
→ Run `./scripts/configure-jenkins.sh squ_ace66e3a638670b72690f829066895eb477eeffb`

**Jenkins UI shows "Please wait while Jenkins is getting ready"?**
→ Wait 1-2 minutes. Jenkins takes time to start.

**SonarQube shows "SonarQube is starting"?**
→ Wait 1-2 minutes. It needs to initialize the database.

**Build fails at "Install"?**
→ Check internet connection. `npm ci` downloads packages.

**Want to see build logs?**
→ http://localhost:8080/job/expense-tracker-pipeline/lastBuild/console
