# Step 2: Install Local Tools

> Everything runs on your Mac using Docker. Let's set it up.

---

## Tool 1: Docker Desktop (Already Installed ✅)

You said you have Docker. Let's verify:

```bash
# Check Docker is running
docker --version
# Should show: Docker version 2X.X.X or similar

docker compose version
# Should show: Docker Compose version v2.X.X

# Quick test
docker run hello-world
# Should show: "Hello from Docker!"
```

### If Docker isn't running:
- Open **Docker Desktop** from your Applications folder
- Wait for the whale icon in the menu bar to stop animating
- Try the commands above again

---

## Tool 2: Node.js (For Your Next.js App)

```bash
# Check if you have Node.js
node --version
# Need: v18.0.0 or higher (recommended: v20+)

npm --version
# Need: v9+ 
```

### If you don't have Node.js:
```bash
# Install using Homebrew (recommended)
brew install node@20

# OR download from https://nodejs.org (LTS version)
```

---

## Tool 3: Git (For Version Control)

```bash
# Check Git
git --version
# Should show: git version 2.X.X
```

### If you don't have Git:
```bash
brew install git
```

---

## Tool 4: Trivy (Security Scanner)

```bash
# Install Trivy
brew install trivy

# Verify
trivy --version
# Should show: Version: 0.X.X
```

**What is Trivy?** A security scanner that checks your code and containers for known vulnerabilities. Like a metal detector at the airport, but for software.

---

## Tool 5: OpenShift CLI (`oc`) — Install Now, Use Later

```bash
# Install oc CLI
brew install openshift-cli

# Verify
oc version
# Should show: Client Version: 4.X.X
```

**What is `oc`?** The command-line tool to talk to OpenShift clusters. Like `kubectl` (Kubernetes CLI) but with extra features.

---

## Tool 6: kubectl (Kubernetes CLI)

```bash
# Install kubectl
brew install kubectl

# Verify
kubectl version --client
# Should show: Client Version: v1.X.X
```

**What is kubectl?** The command-line tool to talk to any Kubernetes cluster. `oc` includes everything `kubectl` does, plus OpenShift-specific stuff.

---

## Verify All Tools

Run this one-liner to check everything:

```bash
echo "=== Tool Check ===" && \
echo "Docker: $(docker --version 2>/dev/null || echo 'NOT INSTALLED')" && \
echo "Node:   $(node --version 2>/dev/null || echo 'NOT INSTALLED')" && \
echo "npm:    $(npm --version 2>/dev/null || echo 'NOT INSTALLED')" && \
echo "Git:    $(git --version 2>/dev/null || echo 'NOT INSTALLED')" && \
echo "Trivy:  $(trivy --version 2>/dev/null | head -1 || echo 'NOT INSTALLED')" && \
echo "oc:     $(oc version --client 2>/dev/null | head -1 || echo 'NOT INSTALLED')" && \
echo "kubectl: $(kubectl version --client --short 2>/dev/null || echo 'NOT INSTALLED')" && \
echo "=== Done ==="
```

### Expected output:
```
=== Tool Check ===
Docker:  Docker version 2X.X.X
Node:    v20.X.X
npm:     10.X.X
Git:     git version 2.X.X
Trivy:   Version: 0.X.X
oc:      Client Version: 4.X.X
kubectl: Client Version: v1.X.X
=== Done ===
```

---

## Allocate Docker Resources

Jenkins + SonarQube are hungry. Give Docker enough resources:

1. Open **Docker Desktop**
2. Click **Settings** (gear icon)
3. Go to **Resources**
4. Set:
   - **CPUs**: 4 (minimum 2)
   - **Memory**: 8 GB (minimum 6 GB)
   - **Disk**: 40 GB+
5. Click **Apply & Restart**

### Why?
- Jenkins needs ~1-2 GB RAM
- SonarQube needs ~2-3 GB RAM (Elasticsearch is hungry)
- Your app needs ~512 MB
- Leave some for your Mac

---

## Next Step
👉 Go to [03-build-nextjs-app.md](03-build-nextjs-app.md) to create your Expense Tracker app
