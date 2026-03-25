# Step 4: Jenkins Pipeline 101

> Jenkins is the BOSS of your pipeline. Let's set it up and understand it.

---

## What is Jenkins?

**Simple**: Jenkins is a robot that runs tasks for you automatically when you push code.

**Real talk**: Jenkins is an open-source automation server. When you push code to GitHub, Jenkins:
1. Pulls your code
2. Installs dependencies
3. Builds your app
4. Runs tests
5. Does whatever else you tell it to

It's like having an employee who never sleeps and follows instructions perfectly.

---

## Start Jenkins + SonarQube

Everything is pre-configured in `docker-compose.yml`. One command:

```bash
cd /Volumes/POOVENDHAN/DOCUMENTS/TestJenkinsSonarOcp

# Start all services
docker compose up -d

# Check everything is running
docker compose ps
```

You should see:
```
NAME              STATUS     PORTS
jenkins           running    0.0.0.0:8080->8080/tcp
sonarqube         running    0.0.0.0:9000->9000/tcp
sonarqube-db      running    5432/tcp
```

Wait 2-3 minutes for everything to boot up.

---

## First Time Jenkins Setup

### 1. Get the Admin Password
```bash
# Get the initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
Copy this password.

### 2. Open Jenkins
- Go to **http://localhost:8080**
- Paste the password
- Click **"Install suggested plugins"** (wait 5-10 minutes)
- Create your admin user:
  - Username: `admin`
  - Password: `admin` (it's local, don't worry)
  - Full name: Your Name
  - Email: your@email.com
- Click **"Save and Continue"**
- Jenkins URL: leave as `http://localhost:8080/`
- Click **"Start using Jenkins"**

### 3. Install Extra Plugins
Go to **Manage Jenkins → Plugins → Available Plugins**

Search and install these:
- ✅ **NodeJS** — runs npm commands
- ✅ **SonarQube Scanner** — integrates SonarQube
- ✅ **Docker Pipeline** — builds Docker images
- ✅ **Pipeline: Stage View** — visual pipeline stages
- ✅ **HTML Publisher** — shows test coverage reports

Click **"Install"** and restart Jenkins when done.

### 4. Configure Node.js
Go to **Manage Jenkins → Tools**

Scroll to **NodeJS installations**:
- Click **"Add NodeJS"**
- Name: `NodeJS-20`
- Version: `20.x.x` (latest 20)
- Click **"Save"**

### 5. Configure SonarQube Server
Go to **Manage Jenkins → System**

Scroll to **SonarQube servers**:
- Click **"Add SonarQube"**
- Name: `SonarQube`
- Server URL: `http://sonarqube:9000` (Docker network name!)
- Server authentication token: (we'll create this in Step 5)
- Click **"Save"**

---

## Understanding the Jenkinsfile

The `Jenkinsfile` is like a **recipe** that tells Jenkins what to do. It lives in your project root.

### Basic Structure:
```groovy
pipeline {
    // WHERE to run (which computer)
    agent any

    // TOOLS needed
    tools {
        nodejs 'NodeJS-20'
    }

    // THE STEPS (in order)
    stages {
        stage('Checkout') {
            steps {
                // Get code from Git
                checkout scm
            }
        }

        stage('Install') {
            steps {
                // Install npm packages
                sh 'npm ci'
            }
        }

        stage('Build') {
            steps {
                // Build the app
                sh 'npm run build'
            }
        }

        stage('Test') {
            steps {
                // Run tests
                sh 'npm test'
            }
        }
    }

    // WHAT TO DO AFTER (success or failure)
    post {
        success {
            echo '✅ Pipeline passed!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
```

### Key Concepts:
| Term | What It Means | Pizza Analogy |
|------|--------------|---------------|
| `pipeline` | The whole recipe | The pizza menu |
| `agent` | Which computer runs it | Which kitchen |
| `tools` | Software needed | Kitchen tools |
| `stages` | Groups of steps | Stations on the line |
| `stage` | One group of steps | One station (e.g., "add toppings") |
| `steps` | Individual commands | Individual actions |
| `post` | Runs at the end | Cleanup after cooking |
| `sh` | Run a terminal command | "Do this specific thing" |

---

## Create Your First Pipeline Job

### 1. Create a New Job
- Go to Jenkins dashboard: http://localhost:8080
- Click **"New Item"**
- Name: `expense-tracker-pipeline`
- Choose **"Pipeline"**
- Click **"OK"**

### 2. Configure the Job
In the Pipeline section:
- Definition: **"Pipeline script from SCM"**
- SCM: **Git**
- Repository URL: Your GitHub repo URL
  - e.g., `https://github.com/YOUR-USERNAME/TestJenkinsSonarOcp.git`
- Credentials: (add your GitHub credentials if private repo)
- Branch: `*/develop` (for UAT)
- Script Path: `Jenkinsfile`
- Click **"Save"**

### 3. Run It!
- Click **"Build Now"**
- Watch the stages light up green (or red if something fails)
- Click on the build number → **"Console Output"** to see every detail

---

## What to Expect

First run might take 5+ minutes (downloading Node.js, installing packages).

Successful pipeline looks like:
```
[Pipeline] stage (Checkout)     ✅
[Pipeline] stage (Install)      ✅
[Pipeline] stage (Build)        ✅
[Pipeline] stage (Test)         ✅
Finished: SUCCESS
```

Failed pipeline shows which stage broke and why. **This is normal — reading error messages is how you learn!**

---

## Common First-Time Issues

| Problem | Fix |
|---------|-----|
| "Jenkins can't connect to Git" | Check your repo URL, make sure it's public or add credentials |
| "npm not found" | Make sure NodeJS tool is configured (Step 4 above) |
| "Permission denied" | Run `docker exec -u root jenkins chmod -R 777 /var/jenkins_home` |
| "Build takes forever" | First build downloads everything. Second build will be faster. |

---

## Checkpoint ✅

Before moving on, verify:
- [ ] Jenkins is running at http://localhost:8080
- [ ] You created a pipeline job
- [ ] The pipeline runs: Checkout → Install → Build → Test
- [ ] All stages are GREEN

---

## Next Step
👉 Go to [05-sonarqube-integration.md](05-sonarqube-integration.md) to add code quality scanning
