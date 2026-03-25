# The Big Picture — What Are We Building?

> Imagine you're 10 years old. Let's explain everything with a story.

---

## The Pizza Factory Analogy 🍕

Imagine you own a **pizza factory**. Every time a customer orders a pizza:

1. **Someone makes the dough** (= `npm install` — getting ingredients)
2. **Someone shapes it** (= `npm run build` — building your app)
3. **A food inspector checks it** (= `npm test` — running tests)
4. **A health inspector visits** (= SonarQube — checking code quality)
5. **A security guard checks for bad ingredients** (= Trivy/OWASP — security scan)
6. **Pizza goes to the testing table** (= Deploy to UAT — let testers try it)
7. **Manager says "looks good, ship it!"** (= Approval Gate)
8. **Pizza delivered to customer** (= Deploy to Production)

**Jenkins is the FACTORY MANAGER** — it makes sure every step happens in order, and if any step fails, the pizza doesn't get delivered.

---

## What Each Tool Does

```
┌─────────────────────────────────────────────────────────────────┐
│                        YOUR COMPUTER                            │
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌───────────────┐             │
│  │  Your     │    │ Jenkins  │    │  SonarQube    │             │
│  │  Code     │───▶│ (Boss)   │───▶│  (Inspector)  │             │
│  │  (Next.js)│    │ Port 8080│    │  Port 9000    │             │
│  └──────────┘    └────┬─────┘    └───────────────┘             │
│                       │                                         │
│                       ▼                                         │
│              ┌────────────────┐                                 │
│              │ Trivy + OWASP  │                                 │
│              │ (Security      │                                 │
│              │  Guards)       │                                 │
│              └────────┬───────┘                                 │
│                       │                                         │
└───────────────────────┼─────────────────────────────────────────┘
                        │
                        ▼
         ┌──────────────────────────────┐
         │         INTERNET             │
         │                              │
         │  Phase 1: Vercel             │
         │  ┌─────────┐ ┌─────────┐    │
         │  │   UAT   │ │  PROD   │    │
         │  │(testing)│ │ (real)  │    │
         │  └─────────┘ └─────────┘    │
         │                              │
         │  Phase 2: OpenShift (AWS)    │
         │  ┌─────────┐ ┌─────────┐    │
         │  │   UAT   │ │  PROD   │    │
         │  │namespace│ │namespace│    │
         │  └─────────┘ └─────────┘    │
         └──────────────────────────────┘
```

---

## The Pipeline — Step by Step

```
  You push code to GitHub
         │
         ▼
  ┌─── JENKINS PIPELINE ──────────────────────────────────────┐
  │                                                            │
  │  1. CHECKOUT ──▶ Get your code from GitHub                 │
  │       │                                                    │
  │  2. INSTALL ──▶ npm ci (install packages)                  │
  │       │                                                    │
  │  3. LINT ──▶ Check code style (ESLint)                     │
  │       │                                                    │
  │  4. BUILD ──▶ npm run build (compile your app)             │
  │       │                                                    │
  │  5. TEST ──▶ npm test (run all tests)                      │
  │       │                                                    │
  │  6. SONARQUBE ──▶ Deep code quality scan                   │
  │       │           (bugs? code smells? duplications?)       │
  │       │                                                    │
  │  7. SECURITY SCAN ──▶ Trivy + OWASP                       │
  │       │                (vulnerable packages?)              │
  │       │                                                    │
  │  8. DEPLOY TO UAT ──▶ Ship to testing environment          │
  │       │                                                    │
  │  9. SMOKE TEST ──▶ Quick check: is UAT site alive?         │
  │       │                                                    │
  │  10. APPROVAL GATE ──▶ Human says "yes, deploy to prod"    │
  │       │                                                    │
  │  11. DEPLOY TO PROD ──▶ Ship to production!                │
  │                                                            │
  └────────────────────────────────────────────────────────────┘
```

---

## Two Environments — Why?

| Environment | Branch | Purpose | Who Uses It |
|-------------|--------|---------|-------------|
| **UAT** (User Acceptance Testing) | `develop` | Test new features before they go live | Testers, QA team |
| **Production** | `main` | The real website that real users see | Everyone |

**Rule**: Code goes to UAT first. Only after someone approves it, it goes to Production.

Think of it like: **rehearsal** (UAT) before the **real show** (Production).

---

## Two Phases — Why?

### Phase 1: Vercel (Easy Mode)
- Vercel is like a **magic box** — you push code, it deploys automatically
- Great for learning the pipeline basics without worrying about servers
- Free tier is perfect for learning

### Phase 2: OpenShift/Kubernetes (Boss Mode)
- OpenShift is what **big companies** use (banks, airlines, governments)
- Your app runs inside **containers** (like shipping containers for software)
- Kubernetes manages those containers (starts them, restarts them if they crash, scales them up)
- OpenShift = Kubernetes + extra enterprise features from Red Hat

---

## What You'll Learn (in order)

1. **How to build a pipeline** — Jenkins automation
2. **How to check code quality** — SonarQube analysis
3. **How to scan for security holes** — Trivy + OWASP
4. **How to deploy to the cloud** — Vercel (easy) then OpenShift (enterprise)
5. **How containers work** — Docker
6. **How to orchestrate containers** — Kubernetes/OpenShift
7. **How UAT → Approval → Prod works** — Enterprise release process

---

## Next Step
👉 Go to [01-accounts-setup.md](01-accounts-setup.md) to create your accounts
