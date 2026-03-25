# Step 8: Containerize Your App

> Put your app in a container so it can run anywhere — your Mac, a server, the cloud, OpenShift.

---

## What is a Container?

**Simple**: A container is a **box** that holds your app + everything it needs to run. The box works the same everywhere.

**Real talk**: A Docker container packages your app with its dependencies, runtime, and OS libraries into a single image. It runs identically on any machine with Docker.

### The Moving Analogy
Imagine moving to a new house:
- **Without containers**: Pack your stuff, hope the new house has the right outlets, hope the furniture fits
- **With containers**: Put your entire room (walls, outlets, furniture, everything) into a shipping container. Drop it at the new house. It works exactly the same.

---

## The Dockerfile

The `Dockerfile` is already in your project root. Here's what each part does:

```dockerfile
# ---- Step 1: BUILD ----
# Start with a Node.js image
FROM node:20-alpine AS builder

# Set working directory inside the container
WORKDIR /app

# Copy package files first (for Docker layer caching)
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy all source code
COPY . .

# Build the Next.js app
RUN npm run build

# ---- Step 2: RUN ----
# Start fresh with a smaller image
FROM node:20-alpine AS runner

WORKDIR /app

# Don't run as root (security best practice)
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy only what we need from the build step
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Switch to non-root user
USER nextjs

# The app listens on port 3000
EXPOSE 3000

# Start the app
CMD ["node", "server.js"]
```

### Why Two Steps? (Multi-Stage Build)
```
Step 1 (Builder): ~1 GB         Step 2 (Runner): ~150 MB
┌─────────────────────┐         ┌─────────────────────┐
│ Node.js             │         │ Node.js             │
│ ALL npm packages    │    →    │ Only production     │
│ Source code         │  copy   │ Built .next files   │
│ Dev dependencies    │ needed  │ Public assets       │
│ Build tools         │  files  │                     │
│ Tests               │         │ 85% SMALLER!        │
└─────────────────────┘         └─────────────────────┘
```

We build in a big container, then copy only the production files to a small container. This means:
- Smaller image = faster downloads
- No dev tools in production = more secure
- No source code in production = more secure

---

## Build and Run Locally

```bash
cd /Volumes/POOVENDHAN/DOCUMENTS/TestJenkinsSonarOcp

# Build the Docker image
docker build -t expense-tracker:latest .

# Run it
docker run -p 3000:3000 expense-tracker:latest

# Open http://localhost:3000 — your app is running in a container!
```

### Useful Docker Commands:
```bash
# See running containers
docker ps

# See all images
docker images

# Stop the container
docker stop $(docker ps -q --filter ancestor=expense-tracker:latest)

# Check image size
docker images expense-tracker
# Should be ~150-200 MB (not 1 GB!)
```

---

## Security Scan the Container

Now scan your container image for vulnerabilities:

```bash
# Scan with Trivy
trivy image expense-tracker:latest

# Only show HIGH and CRITICAL
trivy image --severity HIGH,CRITICAL expense-tracker:latest
```

This checks:
- The base image (node:20-alpine) for OS package vulnerabilities
- Your app's npm packages
- Common misconfigurations

---

## Push to Docker Hub

```bash
# Login to Docker Hub
docker login

# Tag your image (replace YOUR-USERNAME)
docker tag expense-tracker:latest YOUR-USERNAME/expense-tracker:latest

# Push it
docker push YOUR-USERNAME/expense-tracker:latest
```

Now your image is stored on Docker Hub and can be pulled from anywhere (including OpenShift).

---

## In the Jenkins Pipeline

The Jenkinsfile includes a Docker build stage:

```groovy
stage('Build Docker Image') {
    steps {
        sh "docker build -t expense-tracker:${BUILD_NUMBER} ."
        sh "docker tag expense-tracker:${BUILD_NUMBER} expense-tracker:latest"
    }
}

stage('Scan Container Image') {
    steps {
        sh "trivy image --severity HIGH,CRITICAL --exit-code 1 expense-tracker:${BUILD_NUMBER}"
    }
}

stage('Push to Registry') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'dockerhub-creds',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
        )]) {
            sh '''
                echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                docker tag expense-tracker:${BUILD_NUMBER} $DOCKER_USER/expense-tracker:${BUILD_NUMBER}
                docker push $DOCKER_USER/expense-tracker:${BUILD_NUMBER}
            '''
        }
    }
}
```

---

## Key Concepts

| Concept | Meaning | Analogy |
|---------|---------|---------|
| **Image** | A snapshot/template of your app | A recipe |
| **Container** | A running instance of an image | A pizza made from the recipe |
| **Registry** | Where images are stored | A recipe book (Docker Hub) |
| **Tag** | A version label on an image | "v1.0", "latest", build number |
| **Multi-stage build** | Build in one image, run in another | Cook in the kitchen, serve in the dining room |
| **alpine** | Tiny Linux (5 MB vs 100 MB) | A studio apartment vs a mansion |

---

## Checkpoint ✅

Before moving on, verify:
- [ ] `docker build -t expense-tracker .` succeeds
- [ ] `docker run -p 3000:3000 expense-tracker` serves the app
- [ ] `trivy image expense-tracker` shows scan results
- [ ] Image pushed to Docker Hub (optional for now)
- [ ] You understand multi-stage builds

---

## Next Step
👉 Go to [09-openshift-migration.md](09-openshift-migration.md) to deploy to OpenShift!
