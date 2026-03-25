# Step 9: Deploy to OpenShift (Kubernetes)

> This is the boss level. Your app will run on enterprise-grade infrastructure.

---

## What is Kubernetes?

**Simple**: Kubernetes (K8s) is a robot that manages your containers. It starts them, stops them, restarts them if they crash, and makes more copies if lots of people visit your site.

**Real talk**: Kubernetes is a container orchestration platform. It manages the lifecycle of containers across a cluster of machines.

## What is OpenShift?

**Simple**: OpenShift is Kubernetes wearing a business suit. Same thing underneath, but with extra features for big companies.

**Real talk**: OpenShift = Kubernetes + Red Hat enterprise features:
- Built-in CI/CD (Source-to-Image builds)
- Developer-friendly web console
- Built-in monitoring and logging  
- Security policies (Security Context Constraints)
- Routes (OpenShift's version of Ingress)

```
Kubernetes         OpenShift
┌──────────┐      ┌──────────────────┐
│ Core K8s │      │ Core K8s         │
│ Engine   │      │ Engine           │
│          │  ←   │ + Web Console    │
│          │      │ + Routes         │
│          │      │ + SCC (Security) │
│          │      │ + S2I (Builds)   │
│          │      │ + Operators      │
└──────────┘      └──────────────────┘
```

---

## Option A: Red Hat Developer Sandbox (Recommended — Free)

### Setup:
1. Go to **https://developers.redhat.com/developer-sandbox**
2. Click **"Start your sandbox"** (you created the account earlier)
3. Click **"Launch"** to open the OpenShift Web Console
4. Note the cluster URL (you'll need it)

### Login via CLI:
1. In the OpenShift web console, click your name → **"Copy login command"**
2. Click **"Display Token"**
3. Copy the `oc login` command:
```bash
oc login --token=sha256~XXXXX --server=https://api.sandbox-XXXXX.openshiftapps.com:6443
```

4. Run it in your terminal. You're now connected!

### Your Namespaces:
The sandbox gives you 2 namespaces (like folders for organizing your deployments):
```bash
# See your namespaces
oc projects
# You'll see: YOUR-USERNAME-dev and YOUR-USERNAME-stage
```

We'll use:
- `YOUR-USERNAME-dev` → **UAT environment**
- `YOUR-USERNAME-stage` → **Production environment**

---

## Option B: CodeReady Containers (CRC — Local)

If you want OpenShift running on your Mac:

```bash
# Install
brew install crc

# Setup (downloads ~4 GB, takes 10-15 minutes)
crc setup

# Start (takes 5-10 minutes)
crc start
# Note the kubeadmin password it shows!

# Login
eval $(crc oc-env)
oc login -u kubeadmin -p XXXXX https://api.crc.testing:6443
```

Requirements: 4+ CPUs, 9+ GB RAM, 40+ GB disk.

---

## Key Kubernetes/OpenShift Concepts

| Concept | What It Is | Analogy |
|---------|-----------|---------|
| **Pod** | Smallest unit. Contains 1+ containers | A single apartment |
| **Deployment** | Manages pods (how many, which version) | The apartment manager |
| **Service** | A stable address for finding pods | The building's front desk |
| **Route** (OpenShift) | Public URL pointing to a Service | The street address |
| **Namespace/Project** | A folder grouping related resources | A floor in the building |
| **ConfigMap** | Non-secret configuration | A bulletin board |
| **Secret** | Sensitive data (passwords, tokens) | A locked safe |

### How They Connect:
```
Internet User
    │
    ▼
┌───────────┐
│  Route    │ ← Public URL (expense-tracker-uat.apps.sandbox.com)
└─────┬─────┘
      │
┌─────▼─────┐
│  Service  │ ← Internal load balancer (finds healthy pods)
└─────┬─────┘
      │
┌─────▼─────┐  ┌───────────┐  ┌───────────┐
│  Pod 1    │  │  Pod 2    │  │  Pod 3    │ ← Your app running
│ (container)│  │(container)│  │(container)│    in multiple copies
└───────────┘  └───────────┘  └───────────┘
      │              │              │
┌─────▼──────────────▼──────────────▼─────┐
│        Deployment (manages all pods)     │
└──────────────────────────────────────────┘
```

---

## Create Kubernetes Manifests

The `k8s/` folder in your project contains all the deployment files:

### UAT Deployment (`k8s/uat/deployment.yaml`):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: expense-tracker
  namespace: uat
  labels:
    app: expense-tracker
    env: uat
spec:
  replicas: 1                    # 1 copy for UAT (save resources)
  selector:
    matchLabels:
      app: expense-tracker
  template:
    metadata:
      labels:
        app: expense-tracker
        env: uat
    spec:
      containers:
      - name: expense-tracker
        image: YOUR-DOCKERHUB/expense-tracker:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
```

### UAT Service (`k8s/uat/service.yaml`):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: expense-tracker
  namespace: uat
spec:
  selector:
    app: expense-tracker
  ports:
  - port: 80
    targetPort: 3000
```

### UAT Route (`k8s/uat/route.yaml` — OpenShift only):
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: expense-tracker
  namespace: uat
spec:
  to:
    kind: Service
    name: expense-tracker
  port:
    targetPort: 3000
  tls:
    termination: edge
```

Production has the same files but with:
- `namespace: prod`
- `replicas: 2` (more copies for reliability)
- Different resource limits

---

## Deploy Manually (Learn First)

```bash
# Switch to UAT namespace
oc project YOUR-USERNAME-dev

# Apply all UAT manifests
oc apply -f k8s/uat/

# Check status
oc get pods
# NAME                              READY   STATUS    RESTARTS   AGE
# expense-tracker-xxxx-yyyy         1/1     Running   0          30s

# Get the public URL
oc get route expense-tracker
# NAME              HOST/PORT                                    
# expense-tracker   expense-tracker-uat.apps.sandbox-xxx.com

# Open that URL in your browser!
```

### Useful `oc` Commands:
```bash
# See everything in your namespace
oc get all

# See pod logs (like console output)
oc logs deployment/expense-tracker

# See pod details (for debugging)
oc describe pod expense-tracker-xxxx-yyyy

# Restart all pods
oc rollout restart deployment/expense-tracker

# Scale to 3 copies
oc scale deployment/expense-tracker --replicas=3

# Delete everything
oc delete -f k8s/uat/
```

---

## Automate with Jenkins

The final Jenkinsfile includes OpenShift deployment:

```groovy
stage('Deploy to UAT (OpenShift)') {
    when { branch 'develop' }
    steps {
        withCredentials([string(credentialsId: 'oc-token', variable: 'OC_TOKEN')]) {
            sh '''
                oc login --token=$OC_TOKEN --server=$OC_SERVER
                oc project $UAT_NAMESPACE
                oc set image deployment/expense-tracker \
                    expense-tracker=$DOCKER_REGISTRY/expense-tracker:${BUILD_NUMBER}
                oc rollout status deployment/expense-tracker --timeout=120s
            '''
        }
    }
}

stage('Approval Gate') {
    when { branch 'main' }
    steps {
        input(message: 'Deploy to Production?', ok: 'Deploy')
    }
}

stage('Deploy to Production (OpenShift)') {
    when { branch 'main' }
    steps {
        withCredentials([string(credentialsId: 'oc-token', variable: 'OC_TOKEN')]) {
            sh '''
                oc login --token=$OC_TOKEN --server=$OC_SERVER
                oc project $PROD_NAMESPACE
                oc set image deployment/expense-tracker \
                    expense-tracker=$DOCKER_REGISTRY/expense-tracker:${BUILD_NUMBER}
                oc rollout status deployment/expense-tracker --timeout=120s
            '''
        }
    }
}
```

---

## The Complete Pipeline (OpenShift Version)

```
Git Push
  │
  ▼
┌──────────────────────────────────────────────┐
│ JENKINS PIPELINE                              │
│                                               │
│ 1. Checkout ──▶ Get code                      │
│ 2. Install ──▶ npm ci                         │
│ 3. Lint ──▶ ESLint check                      │
│ 4. Build ──▶ npm run build                    │
│ 5. Test ──▶ npm test (with coverage)          │
│ 6. SonarQube ──▶ Code quality scan            │
│ 7. Quality Gate ──▶ Pass/Fail check           │
│ 8. Security Scans ──▶ Trivy + OWASP          │
│ 9. Build Docker Image ──▶ docker build        │
│ 10. Scan Image ──▶ trivy image                │
│ 11. Push to Registry ──▶ docker push          │
│ 12. Deploy to UAT ──▶ oc set image (OpenShift)│
│ 13. Smoke Test ──▶ curl the UAT URL           │
│ 14. Approval Gate ──▶ ⏸️ Human approves        │
│ 15. Deploy to Prod ──▶ oc set image (OpenShift)│
│ 16. Verify ──▶ curl the Prod URL              │
└──────────────────────────────────────────────┘
```

---

## Checkpoint ✅ (Final!)

- [ ] Connected to OpenShift cluster (`oc login`)
- [ ] UAT namespace exists and app is deployed
- [ ] Production namespace exists and app is deployed
- [ ] Jenkins pipeline deploys to OpenShift automatically
- [ ] Full flow works: push → build → test → scan → UAT → approve → Prod
- [ ] You understand Pods, Deployments, Services, Routes

---

## Congratulations! 🎉

You've built an enterprise-grade CI/CD pipeline from scratch:
- **Jenkins** automates your entire workflow
- **SonarQube** ensures code quality
- **Trivy + OWASP** catch security vulnerabilities
- **OpenShift** runs your app in containers
- **Two environments** with an approval gate between them

This is what real companies do. You just learned it by doing it.
