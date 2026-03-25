# Glossary — Every Term Explained Simply

> If a word confuses you, look it up here. Explained like you're 10.

---

## A

**Alpine Linux** — A super tiny version of Linux (5 MB). Used in Docker because smaller = faster.

**API (Application Programming Interface)** — A way for two programs to talk to each other. Like a waiter taking your order to the kitchen.

**Approval Gate** — A pause in the pipeline where a human must click "OK" before code goes to production. Like a teacher checking your homework before you submit it.

**Artifacts** — Files created during a pipeline build (test reports, built app files). Like the leftovers after cooking.

## B

**Branch** — A copy of your code where you can make changes without affecting the main version. Like a draft of an essay.

**Build** — The process of turning your source code into something that can run. Like baking raw dough into bread.

**Build Number** — A number that goes up every time Jenkins runs your pipeline. Build #1, #2, #3... Like counting how many times you've practiced a song.

## C

**CI (Continuous Integration)** — Automatically building and testing code every time someone pushes changes. Like a spell-checker that runs every time you type.

**CD (Continuous Delivery/Deployment)** — Automatically deploying code after it passes all checks. Like auto-submitting your essay after spell-check passes.

**CLI (Command Line Interface)** — A text-based way to talk to a computer. You type commands instead of clicking buttons.

**Cluster** — A group of computers working together as one. Like a team of workers building a house together.

**Container** — A lightweight, portable package that includes your app and everything it needs. Like a lunchbox with your meal + utensils + napkin.

**Container Image** — The blueprint/template for creating containers. Like a recipe that can make many identical dishes.

**Container Registry** — A storage place for container images. Docker Hub, Quay, etc. Like a library for recipes.

**Coverage (Code Coverage)** — How much of your code is tested. 80% coverage = 80% of your code lines are hit by tests.

**CRC (CodeReady Containers)** — A tool to run OpenShift on your laptop. Like a mini version of a big server farm.

**CRITICAL (severity)** — The most serious level of security vulnerability. Fix immediately.

**CVE (Common Vulnerabilities and Exposures)** — A unique ID for a known security bug. Like a serial number for a recalled product. Example: CVE-2021-44228 (Log4j).

**CVSS (Common Vulnerability Scoring System)** — A score from 0-10 rating how dangerous a vulnerability is. 10 = catastrophic.

## D

**Declarative Pipeline** — A Jenkinsfile style that uses a structured format (`pipeline { ... }`). Easier to read than Scripted Pipeline.

**Dependency** — A package your project needs. Like ingredients in a recipe. React, Next.js, and TypeScript are dependencies.

**Deployment (Kubernetes)** — A Kubernetes object that manages your pods. It ensures the right number are running and handles updates.

**Docker** — A tool for creating and running containers. Like a machine that builds and runs shipping containers.

**Docker Compose** — A tool for running multiple Docker containers together with one command. Like a recipe that cooks multiple dishes at once.

**Docker Hub** — The default public container registry. Like the YouTube of container images.

**Dockerfile** — Instructions for building a container image. Like a recipe card.

## E

**Environment** — A separate place where your app runs. UAT = testing, Prod = real. Like a rehearsal stage vs the main stage.

**ESLint** — A tool that checks your JavaScript/TypeScript for mistakes and style issues. Like a grammar checker.

## G

**Git** — Version control software. Tracks every change to your code. Like "undo history" for your entire project.

**GitHub** — A website that hosts Git repositories. Where your code lives online.

**GitFlow** — A branching strategy. `main` = production, `develop` = next release, `feature/*` = work in progress.

## H

**Helm** — A package manager for Kubernetes. Like `npm` but for K8s deployments.

**HIGH (severity)** — A serious security vulnerability. Should be fixed soon.

## I

**Image** — See "Container Image".

**Ingress** — A Kubernetes way to expose your app to the internet. OpenShift uses "Routes" instead.

## J

**Jenkins** — An automation server. It runs your CI/CD pipeline. Like a robot factory worker.

**Jenkinsfile** — A file that defines your Jenkins pipeline. The "recipe" for your automation.

**JUnit** — A test report format. Jenkins can read JUnit XML reports to show pass/fail results.

## K

**kubectl** — The command-line tool for Kubernetes. Like a remote control for your cluster.

**Kubernetes (K8s)** — Container orchestration platform. Manages containers at scale. Like an air traffic controller for containers.

## L

**Lint / Linting** — Checking code for style issues and common mistakes. Not about bugs — about cleanliness.

**localStorage** — Browser storage that survives page refreshes. Like a sticky note on your browser that stays there.

**LTS (Long Term Support)** — A version that gets security updates for a long time. Stable and safe choice.

## M

**Manifest** — A YAML file that describes what to deploy on Kubernetes. Like a blueprint for a building.

**Multi-stage Build** — A Docker technique where you build in one image and run in a smaller one. Saves space and improves security.

## N

**Namespace** — A way to organize resources in Kubernetes. Like folders on your computer.

**Next.js** — A React framework for building web apps. Created by Vercel.

**Node.js** — A JavaScript runtime. Lets you run JavaScript outside the browser.

**npm** — Node Package Manager. Installs JavaScript packages. Like an app store for code libraries.

**NVD (National Vulnerability Database)** — The US government's database of known security vulnerabilities.

## O

**`oc`** — OpenShift CLI (command-line tool). Like kubectl but with extra OpenShift features.

**OCP (OpenShift Container Platform)** — The enterprise version of OpenShift. What big companies pay for.

**OKD** — The free, community version of OpenShift.

**OpenShift** — Red Hat's enterprise Kubernetes platform. Kubernetes + extra features + support.

**OWASP** — Open Web Application Security Project. A non-profit focused on software security.

**OWASP Dependency-Check** — A free tool that scans your dependencies for known vulnerabilities.

## P

**Pipeline** — A sequence of automated steps that code goes through. Build → Test → Scan → Deploy.

**Pod** — The smallest unit in Kubernetes. Usually contains one container. Like a single apartment.

**Port** — A number that identifies a network connection. Port 3000 = your Next.js app, Port 8080 = Jenkins, Port 9000 = SonarQube.

**Post (Jenkins)** — Actions that run after all stages complete (success or failure). Like cleanup after cooking.

**Production (Prod)** — The live environment where real users use your app.

## Q

**Quality Gate** — A set of rules in SonarQube. If your code doesn't meet them, the gate fails and deployment stops.

## R

**Registry** — See "Container Registry".

**Replica** — A copy of your pod. 3 replicas = 3 copies of your app running simultaneously.

**ROSA** — Red Hat OpenShift Service on AWS. Managed OpenShift in the cloud. Paid service.

**Route (OpenShift)** — A public URL that points to your app inside the cluster. Like a street address.

**Rollout** — The process of deploying a new version of your app. Kubernetes replaces old pods with new ones gradually.

## S

**SCC (Security Context Constraints)** — OpenShift security rules. Controls what containers can do (run as root? access host network?).

**SCM (Source Code Management)** — A system for tracking code changes. Git is the most popular SCM.

**Secret (Kubernetes)** — Sensitive data stored in the cluster (passwords, tokens). Encrypted and access-controlled.

**Service (Kubernetes)** — An internal address that finds and load-balances across your pods.

**Smoke Test** — A quick test to check if the deployed app is alive and responding.

**SonarQube** — A code quality platform. Scans code for bugs, vulnerabilities, and code smells.

**Stage (Jenkins)** — A named group of steps in a pipeline. Like a chapter in a book.

## T

**Tag (Docker)** — A version label for a container image. Like `v1.0`, `latest`, or `build-42`.

**Token** — A secret key that grants access. Like a password but generated by the system.

**Trivy** — An open-source security scanner by Aqua Security. Scans code, containers, and configs.

**TypeScript** — JavaScript with type checking. Catches errors before you run the code.

## U

**UAT (User Acceptance Testing)** — An environment where testers verify the app before it goes to production. Like a dress rehearsal.

## V

**Vercel** — A cloud platform for deploying frontend apps. Created Next.js.

**Vulnerability** — A security weakness that could be exploited by attackers.

## W

**Webhook** — An automatic notification sent when something happens. GitHub sends a webhook to Jenkins when you push code.

**Worker Node** — A computer in the cluster that runs your containers. The actual machine doing the work.

## Y

**YAML** — A data format used for configuration files. Uses indentation (like Python). Kubernetes manifests are written in YAML.
