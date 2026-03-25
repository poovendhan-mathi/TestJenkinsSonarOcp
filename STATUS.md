# STATUS TRACKER — Jenkins Pipeline Learning Project

> Last updated: 2025-03-25
> Current Phase: **Phase 1 — Foundation**

---

## Phase 1: Foundation (Local Setup)
- [ ] Step 1: Create GitHub account (if needed)
- [ ] Step 2: Create Vercel account (sign up with GitHub)
- [ ] Step 3: Create Red Hat Developer account
- [ ] Step 4: Create Docker Hub account
- [ ] Step 5: Verify Docker Desktop is running on Mac
- [ ] Step 6: Project structure created ✅ (you're reading this!)
- [ ] Step 7: Next.js Expense Tracker app runs at localhost:3000
- [ ] Step 8: Tests pass (`npm test`)
- **Checkpoint**: App runs locally, tests pass

## Phase 2: Jenkins + SonarQube (Local Docker)
- [ ] Step 9: `docker-compose up` starts Jenkins + SonarQube
- [ ] Step 10: Access Jenkins at http://localhost:8080
- [ ] Step 11: Access SonarQube at http://localhost:9000
- [ ] Step 12: Configure Jenkins — install plugins, create pipeline job
- [ ] Step 13: Connect Jenkins to your Git repo
- [ ] Step 14: Basic Jenkinsfile runs: checkout → install → build → test
- [ ] Step 15: SonarQube project created, token generated
- [ ] Step 16: SonarQube scanner integrated into Jenkinsfile
- [ ] Step 17: Quality Gate configured — pipeline fails on bad code
- **Checkpoint**: Push code → Jenkins builds → SonarQube shows report

## Phase 3: Security Scanning
- [ ] Step 18: Trivy installed in Jenkins container
- [ ] Step 19: Trivy filesystem scan added to pipeline
- [ ] Step 20: OWASP Dependency-Check added to pipeline
- [ ] Step 21: Pipeline fails on CRITICAL vulnerabilities
- [ ] Step 22: Review and understand a scan report
- **Checkpoint**: Pipeline catches known vulnerabilities

## Phase 4: Deploy to Vercel (UAT + Prod)
- [ ] Step 23: GitHub repo connected to Vercel
- [ ] Step 24: Vercel Preview = UAT environment configured
- [ ] Step 25: Vercel Production environment configured
- [ ] Step 26: Jenkinsfile.vercel deploys to UAT on `develop` push
- [ ] Step 27: Approval gate added before production deploy
- [ ] Step 28: Smoke test runs after UAT deployment
- [ ] Step 29: Full flow tested: develop → UAT → approve → main → Prod
- **Checkpoint**: develop branch → UAT site, main branch (after approval) → Prod site

## Phase 5: Containerize & OpenShift
- [ ] Step 30: Dockerfile created and tested locally
- [ ] Step 31: Docker image builds and runs at localhost:3000
- [ ] Step 32: Image pushed to Docker Hub (or OpenShift registry)
- [ ] Step 33: Red Hat Developer Sandbox activated OR CRC installed
- [ ] Step 34: `oc` CLI installed and logged into cluster
- [ ] Step 35: UAT namespace created in OpenShift
- [ ] Step 36: Prod namespace created in OpenShift
- [ ] Step 37: Deployment + Service + Route created for UAT
- [ ] Step 38: Deployment + Service + Route created for Prod
- [ ] Step 39: Jenkinsfile updated to deploy to OpenShift
- [ ] Step 40: Full flow: push → build → test → scan → deploy UAT → approve → deploy Prod
- **Checkpoint**: Enterprise-grade pipeline running on OpenShift

---

## Quick Links
| Tool | URL | Notes |
|------|-----|-------|
| Jenkins | http://localhost:8080 | Local Docker |
| SonarQube | http://localhost:9000 | Default login: admin/admin |
| App (local) | http://localhost:3000 | Next.js dev server |
| Vercel Dashboard | https://vercel.com/dashboard | After account setup |
| OpenShift Console | TBD | After Phase 5 setup |
