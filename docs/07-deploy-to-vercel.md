# Step 7: Deploy to Vercel (UAT + Prod)

> Time to ship your app to the internet! Vercel makes this ridiculously easy.

---

## What is Vercel?

**Simple**: Vercel takes your code from GitHub and puts your website on the internet. Automatically.

**Real talk**: Vercel is a cloud platform optimized for frontend frameworks (especially Next.js — they created it!). It gives you:
- Automatic deployments on every push
- Preview URLs for every branch (our UAT!)
- A production URL for the main branch

---

## Our Two Environments on Vercel

| Environment | Branch | URL Pattern | Purpose |
|-------------|--------|-------------|---------|
| **UAT** (Preview) | `develop` | `your-app-git-develop-username.vercel.app` | Testing |
| **Production** | `main` | `your-app.vercel.app` | Real users |

### How it maps to our pipeline:
```
develop branch push
    │
    ▼
Jenkins Pipeline
    │ (build, test, scan, etc.)
    ▼
Deploy to Vercel Preview ← This is UAT
    │
    ▼
Manual Approval
    │
    ▼
Merge to main
    │
    ▼
Jenkins Pipeline
    │ (build, test, scan again)
    ▼
Deploy to Vercel Production ← This is PROD
```

---

## Setup Step 1: Connect GitHub Repo to Vercel

1. Go to **https://vercel.com/dashboard**
2. Click **"Add New Project"**
3. Import from GitHub → Select your **TestJenkinsSonarOcp** repo
4. Framework Preset: **Next.js** (auto-detected)
5. Root Directory: `.` (leave as default)
6. Click **"Deploy"**
7. Wait for the first deployment to complete
8. You'll get a URL like: `https://test-jenkins-sonar-ocp.vercel.app`

That's it! Your app is on the internet.

---

## Setup Step 2: Get Vercel Token for Jenkins

For Jenkins to deploy to Vercel, it needs a token:

1. Go to **https://vercel.com/account/tokens**
2. Click **"Create Token"**
3. Name: `jenkins-deploy`
4. Scope: Full Account
5. Expiration: No expiration (or 1 year)
6. Click **"Create"**
7. **COPY THE TOKEN** — you can't see it again!

### Add Token to Jenkins:
1. Go to Jenkins → **Manage Jenkins → Credentials → Global**
2. Click **"Add Credentials"**
3. Kind: **Secret text**
4. Secret: Paste your Vercel token
5. ID: `vercel-token`
6. Description: `Vercel Deployment Token`

### Get Your Vercel Org ID and Project ID:
```bash
# Install Vercel CLI
npm i -g vercel

# Link your project (run in your project directory)
cd /Volumes/POOVENDHAN/DOCUMENTS/TestJenkinsSonarOcp
vercel link
# Follow the prompts to link to your Vercel project
```

After linking, check `.vercel/project.json`:
```json
{
  "orgId": "your-org-id",
  "projectId": "your-project-id"
}
```

Add these to Jenkins as credentials too (Secret text):
- ID: `vercel-org-id`, Secret: your org ID
- ID: `vercel-project-id`, Secret: your project ID

---

## Setup Step 3: Vercel Environment Variables (If Needed)

Your expense tracker uses localStorage so there are no environment variables needed. But for reference:

1. Go to Vercel Dashboard → Your Project → **Settings → Environment Variables**
2. You can add variables per environment:
   - **Production** — only for `main` branch
   - **Preview** — for all other branches (our UAT)
   - **Development** — for `vercel dev` locally

---

## The Vercel Jenkinsfile

The `Jenkinsfile.vercel` handles deployment:

```groovy
// This stage deploys to Vercel Preview (UAT)
stage('Deploy to UAT (Vercel Preview)') {
    when {
        branch 'develop'
    }
    steps {
        withCredentials([
            string(credentialsId: 'vercel-token', variable: 'VERCEL_TOKEN'),
            string(credentialsId: 'vercel-org-id', variable: 'VERCEL_ORG_ID'),
            string(credentialsId: 'vercel-project-id', variable: 'VERCEL_PROJECT_ID')
        ]) {
            sh '''
                npx vercel deploy \
                    --token=$VERCEL_TOKEN \
                    --yes
            '''
        }
    }
}

// This stage deploys to Vercel Production
stage('Deploy to Production') {
    when {
        branch 'main'
    }
    steps {
        // APPROVAL GATE - A human must click "Proceed"
        input(message: 'Deploy to Production?', ok: 'Deploy')

        withCredentials([...]) {
            sh '''
                npx vercel deploy \
                    --prod \
                    --token=$VERCEL_TOKEN \
                    --yes
            '''
        }
    }
}
```

---

## The Approval Gate

This is a big deal in enterprise CI/CD. Before code goes to production:

1. Pipeline **pauses** at the approval stage
2. Someone (team lead, release manager) **reviews** the UAT deployment  
3. They click **"Proceed"** in Jenkins to approve
4. Only then does it deploy to production

```
UAT deployed ──▶ ⏸️ WAITING FOR APPROVAL ──▶ 👤 Human clicks "Deploy" ──▶ Production deployed
```

In Jenkins, you'll see a blue pause icon. Click on it to approve or abort.

---

## Smoke Test After UAT

After deploying to UAT, we run a quick check to make sure the site is alive:

```groovy
stage('Smoke Test - UAT') {
    steps {
        sh '''
            # Simple check: is the site responding?
            HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://YOUR-APP-git-develop.vercel.app)
            if [ "$HTTP_STATUS" -ne 200 ]; then
                echo "❌ Smoke test failed! Status: $HTTP_STATUS"
                exit 1
            fi
            echo "✅ Smoke test passed! Status: 200"
        '''
    }
}
```

---

## Full Flow Demo

### Deploy to UAT:
```bash
# 1. Create develop branch
git checkout -b develop

# 2. Make a change (e.g., add a category)
# 3. Commit and push
git add .
git commit -m "feat: add new expense category"
git push origin develop

# 4. Jenkins automatically:
#    - Builds → Tests → SonarQube → Security Scan → Deploys to Vercel Preview
# 5. Check UAT URL — your change is live for testing!
```

### Promote to Production:
```bash
# 1. Create a PR from develop → main
# 2. Review the PR
# 3. Merge the PR
# 4. Jenkins builds the main branch pipeline
# 5. Pipeline pauses at "Deploy to Production?"
# 6. Go to Jenkins → Click "Deploy" to approve
# 7. App deployed to production URL!
```

---

## Checkpoint ✅

Before moving on, verify:
- [ ] App is deployed on Vercel (you can visit the URL)
- [ ] Push to `develop` → Preview deployment (UAT)
- [ ] Push to `main` → Production deployment
- [ ] Jenkins can deploy using Vercel CLI + token
- [ ] Approval gate pauses the pipeline
- [ ] Smoke test checks if UAT is alive

---

## Next Step
👉 Go to [08-containerize-app.md](08-containerize-app.md) to Dockerize your app for OpenShift
