# Step 10: Local Setup Script — How It All Works

> One script to rule them all. Run it, grab a coffee, come back to a working CI/CD environment.

---

## The Big Picture

When you run `./scripts/setup.sh`, here's what happens inside your Mac:

```
  Your Mac (the host)
  ┌──────────────────────────────────────────────────────────────┐
  │                                                              │
  │   Docker Desktop (runs containers)                           │
  │   ┌────────────────────────────────────────────────────────┐ │
  │   │                                                        │ │
  │   │   ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  │ │
  │   │   │  PostgreSQL  │  │  SonarQube  │  │   Jenkins    │  │ │
  │   │   │    (DB)      │──│  (Scanner)  │  │  (Pipeline)  │  │ │
  │   │   │  port: none  │  │  port: 9000 │  │  port: 8080  │  │ │
  │   │   └─────────────┘  └─────────────┘  └──────────────┘  │ │
  │   │         ↑                ↑                ↑            │ │
  │   │         └────────────────┴────────────────┘            │ │
  │   │              cicd-network (they talk here)             │ │
  │   └────────────────────────────────────────────────────────┘ │
  │                                                              │
  │   Your Browser:                                              │
  │     → http://localhost:8080  (Jenkins)                       │
  │     → http://localhost:9000  (SonarQube)                     │
  └──────────────────────────────────────────────────────────────┘
```

---

## The 3 Scripts

| Script | What it does | When to use it |
|--------|-------------|----------------|
| `./scripts/setup.sh` | Builds images, starts everything, waits until ready | First time, or after a teardown |
| `./scripts/status.sh` | Shows if services are running | Quick health check |
| `./scripts/teardown.sh` | Stops everything | Done for the day |
| `./scripts/teardown.sh --full` | Stops everything AND deletes all data | Want a fresh start |

---

## How to Run

```bash
# Make scripts executable (only need to do this once)
chmod +x scripts/*.sh

# Start everything
./scripts/setup.sh

# Check if things are running
./scripts/status.sh

# Stop when you're done for the day
./scripts/teardown.sh

# Nuclear option — delete everything and start fresh
./scripts/teardown.sh --full
```

---

## What the Setup Script Does (Step by Step)

### Step 1: Checks prerequisites
```
✅ Docker is running
✅ Docker Compose is available
✅ Node.js v20.x found
✅ Disk space OK
```
If Docker isn't running, the script stops and tells you to start Docker Desktop.

### Step 2: Builds the Jenkins image
This is the SLOW part (first time only, ~3-5 minutes). It builds a custom Jenkins image that includes:
- **Jenkins LTS** (Long Term Support) with Java 21
- **Docker CLI** — so Jenkins can build Docker images
- **Trivy** — security scanner (our free replacement for JFrog Xray)
- **20+ plugins** — Git, NodeJS, SonarQube, Blue Ocean, Docker Pipeline, etc.

After the first build, Docker caches the layers, so subsequent builds are fast (~10 seconds).

### Step 3: Starts 3 containers

| Container | Image | What it does |
|-----------|-------|-------------|
| `sonarqube-db` | postgres:16-alpine | Database for SonarQube (stores scan results) |
| `sonarqube` | sonarqube:lts-community | Scans your code for bugs, smells, vulnerabilities |
| `jenkins` | Custom (we built it) | Runs your CI/CD pipeline |

They start in order:
1. **PostgreSQL** starts first (SonarQube needs it)
2. **SonarQube** waits for PostgreSQL to be healthy, then starts
3. **Jenkins** starts independently (doesn't need SonarQube to boot)

### Step 4: Waits for services
Jenkins and SonarQube take time to initialize (loading plugins, running migrations). The script pings them every 10 seconds until they respond.

### Step 5: Prints login info
```
JENKINS:    http://localhost:8080   admin / admin123
SONARQUBE:  http://localhost:9000   admin / admin
```

---

## How the Containers Talk to Each Other

All 3 containers are on a Docker network called `cicd-network`. Inside this network:
- Jenkins calls SonarQube at `http://sonarqube:9000` (not localhost!)
- SonarQube calls PostgreSQL at `sonarqube-db:5432`

```
  Your Browser                     Inside Docker Network
  ─────────────                    ────────────────────────
  localhost:8080  ──── maps to ──→  jenkins:8080
  localhost:9000  ──── maps to ──→  sonarqube:9000
                                    sonarqube-db:5432  (no external access)
```

> **Why `sonarqube` and not `localhost`?**
> Inside Docker, containers use each other's NAMES as hostnames.
> From your browser (outside Docker), you use `localhost`.
> From Jenkins (inside Docker), you use `sonarqube`.

---

## Where Data is Stored

Docker uses **volumes** to keep data even when containers restart:

| Volume | What's in it | Why it matters |
|--------|-------------|---------------|
| `jenkins_home` | Jenkins jobs, configs, build history | Your pipeline settings survive restarts |
| `sonarqube_data` | Scan results, project data | Quality reports persist |
| `sonarqube_logs` | SonarQube logs | For debugging |
| `sonarqube_extensions` | SonarQube plugins | Custom rules |
| `postgresql_data` | Database tables | SonarQube's brain |

To see your volumes:
```bash
docker volume ls | grep testjenkinssonarocp
```

---

## Login Credentials

| Service | URL | Username | Password | Notes |
|---------|-----|----------|----------|-------|
| Jenkins | http://localhost:8080 | `admin` | `admin123` | Auto-created by init script |
| SonarQube | http://localhost:9000 | `admin` | `admin` | Will ask you to change on first login |

> **Change these passwords** if you ever expose these services to a network.
> For local learning, these defaults are fine.

---

## Troubleshooting

### "Port 8080 is already in use"
Something else is using port 8080. Find it and stop it:
```bash
lsof -i :8080
# Then kill the process or change the port in docker-compose.yml
```

### "Port 9000 is already in use"
Same idea:
```bash
lsof -i :9000
```

### Jenkins says "Jenkins is getting ready..."
Just wait. It loads plugins on first boot. Can take 2-3 minutes.

### SonarQube shows "SonarQube is starting"
Also normal. First startup takes 1-2 minutes while it creates database tables.

### "Cannot connect to Docker daemon"
Docker Desktop isn't running. Open Docker Desktop and wait for the whale icon to stop animating.

### Out of memory / containers crashing
Docker Desktop needs at least 4GB RAM:
1. Open Docker Desktop
2. Go to Settings → Resources
3. Set Memory to **4GB** or more
4. Click "Apply & Restart"

### Want to start completely fresh?
```bash
./scripts/teardown.sh --full
./scripts/setup.sh
```
This deletes all data and starts from scratch.

---

## What's Running Under the Hood

When you do `docker compose up -d`, Docker reads `docker-compose.yml` and:

1. **Creates a network** called `cicd-network` (a private LAN for containers)
2. **Creates volumes** (virtual hard drives for data)
3. **Pulls images** from Docker Hub (first time only, ~2GB download)
4. **Builds Jenkins image** using `jenkins/Dockerfile` (first time only)
5. **Starts containers** in dependency order
6. **Runs health checks** on PostgreSQL before starting SonarQube

Think of it like plugging in appliances:
- Docker Compose = the power strip
- Each container = an appliance
- The network = the wifi router connecting them
- Volumes = USB drives with saved data

---

## Daily Workflow

```bash
# Morning: Start your CI/CD environment
./scripts/setup.sh

# During the day: Code, test, run pipelines
npm run dev          # Run app locally
# ... make changes ...
# ... trigger Jenkins pipeline ...

# Check status anytime
./scripts/status.sh

# Evening: Stop everything (saves battery/RAM)
./scripts/teardown.sh
```

---

## Next Step
👉 Go to [04-jenkins-pipeline-101.md](04-jenkins-pipeline-101.md) to create your first Jenkins pipeline job
