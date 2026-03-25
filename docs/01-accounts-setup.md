# Step 1: Create Your Accounts

> You need 4 accounts. All FREE. Takes about 15 minutes total.

---

## Account 1: GitHub (Your Code Lives Here)

**What is it?** A website where you store your code. Like Google Drive but for code.

**Already have one?** Skip to Account 2.

### Steps:
1. Go to **https://github.com**
2. Click **"Sign up"**
3. Enter your email, create a password, pick a username
4. Verify your email
5. Done!

### After setup, do this:
```bash
# Tell Git who you are (run in terminal)
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

---

## Account 2: Vercel (Deploys Your App to the Internet)

**What is it?** A platform that takes your code and puts it on the internet. One click.

### Steps:
1. Go to **https://vercel.com**
2. Click **"Sign Up"**
3. Choose **"Continue with GitHub"** (easiest!)
4. Authorize Vercel to read your GitHub repos
5. Done!

### What you get for free:
- 100 deployments per day
- Automatic preview deployments (our UAT!)
- 1 production deployment per project
- Custom domains

---

## Account 3: Red Hat Developer (For OpenShift Later)

**What is it?** Red Hat makes OpenShift (enterprise Kubernetes). Their developer account gives you a free sandbox.

### Steps:
1. Go to **https://developers.redhat.com**
2. Click **"Register"** (top right)
3. Fill in the form (use your real email)
4. Verify your email
5. After signup, go to **https://developers.redhat.com/developer-sandbox**
6. Click **"Start your sandbox"**
7. Follow the steps (phone verification required)

### What you get for free:
- Full OpenShift cluster (shared)
- 2 namespaces (perfect for UAT + Prod!)
- No time limit (currently)
- `oc` CLI access

> **Note**: You won't use this until Phase 5. Just create the account now so it's ready.

---

## Account 4: Docker Hub (Stores Your Container Images)

**What is it?** Like GitHub, but instead of storing code, it stores Docker images (your app packaged in a container).

### Steps:
1. Go to **https://hub.docker.com**
2. Click **"Sign Up"**
3. Create username, email, password
4. Verify your email
5. Done!

### What you get for free:
- 1 private repository
- Unlimited public repositories
- 200 image pulls per 6 hours

---

## Verify Everything

After creating all accounts, fill in this checklist:

```
[ ] GitHub     — Can log in at github.com
[ ] Vercel     — Can log in at vercel.com (connected to GitHub)
[ ] Red Hat    — Can log in at developers.redhat.com
[ ] Docker Hub — Can log in at hub.docker.com
```

---

## What About Paid Tools?

| Tool | Do I Need to Pay? | Our Free Alternative |
|------|-------------------|---------------------|
| JFrog Xray | ❌ We're NOT using it | Trivy (free, open-source) |
| Snyk | Optional (free tier: 200 tests/month) | Trivy + OWASP covers us |
| SonarCloud | We're running SonarQube locally | No account needed |
| AWS | Not needed for Phase 1-4 | OpenShift Developer Sandbox is free |

---

## Next Step
👉 Go to [02-local-tools-setup.md](02-local-tools-setup.md) to install tools on your Mac
