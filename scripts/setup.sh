#!/bin/bash
# ============================================================
#  SETUP SCRIPT — Start Jenkins + SonarQube Locally
# ============================================================
#  This script:
#    1. Checks Docker is running
#    2. Builds & starts all containers
#    3. Waits for each service to be healthy
#    4. Prints login info and URLs
#
#  Usage:  ./scripts/setup.sh
# ============================================================

set -e

# ---- Colors for pretty output ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ---- Helper functions ----
print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  STEP $1: $2${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_ok() {
    echo -e "  ${GREEN}✅ $1${NC}"
}

print_warn() {
    echo -e "  ${YELLOW}⚠️  $1${NC}"
}

print_fail() {
    echo -e "  ${RED}❌ $1${NC}"
}

print_info() {
    echo -e "  ${CYAN}ℹ️  $1${NC}"
}

wait_for_url() {
    local url=$1
    local name=$2
    local max_attempts=$3
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 5 | grep -q "200\|302\|403"; then
            return 0
        fi
        echo -e "  ⏳ Waiting for $name... (attempt $attempt/$max_attempts)"
        sleep 10
        attempt=$((attempt + 1))
    done
    return 1
}

# ============================================================
#  STEP 1: Check Prerequisites
# ============================================================
print_step "1/5" "Checking prerequisites"

# Check Docker
if ! docker info > /dev/null 2>&1; then
    print_fail "Docker is not running!"
    echo "       Please start Docker Desktop and run this script again."
    exit 1
fi
print_ok "Docker is running"

# Check Docker Compose
if ! docker compose version > /dev/null 2>&1; then
    print_fail "Docker Compose not found!"
    echo "       Please install Docker Compose (comes with Docker Desktop)."
    exit 1
fi
print_ok "Docker Compose is available"

# Check Node.js
if ! node --version > /dev/null 2>&1; then
    print_warn "Node.js not found (needed for running app locally, not for CI/CD)"
else
    print_ok "Node.js $(node --version) found"
fi

# Check available disk space (need ~4GB for images)
if command -v df > /dev/null 2>&1; then
    FREE_GB=$(df -g / 2>/dev/null | tail -1 | awk '{print $4}' || echo "?")
    if [ "$FREE_GB" != "?" ] && [ "$FREE_GB" -lt 4 ] 2>/dev/null; then
        print_warn "Low disk space (${FREE_GB}GB free). Need ~4GB for Docker images."
    else
        print_ok "Disk space OK"
    fi
fi

# Check available memory
print_info "Docker needs ~4GB RAM. Make sure Docker Desktop has enough allocated."
print_info "Docker Desktop → Settings → Resources → Memory → Set to 4GB+"

# ============================================================
#  STEP 2: Build Custom Jenkins Image
# ============================================================
print_step "2/5" "Building custom Jenkins image (first time takes 3-5 min)"

cd "$(dirname "$0")/.."  # Go to project root

echo ""
echo "  This builds a Jenkins image with:"
echo "    - Jenkins LTS (JDK 21)"
echo "    - Docker CLI (to build images inside Jenkins)"
echo "    - Trivy (security scanner)"
echo "    - 20+ pre-installed plugins"
echo ""

docker compose build --no-cache jenkins 2>&1 | while IFS= read -r line; do
    # Show only important build lines
    if echo "$line" | grep -qE "^(Step|Successfully| ---)"; then
        echo "  $line"
    fi
done

if [ $? -eq 0 ] || docker compose build jenkins > /dev/null 2>&1; then
    print_ok "Jenkins image built successfully"
else
    print_fail "Jenkins image build failed! Check the output above."
    exit 1
fi

# ============================================================
#  STEP 3: Start All Services
# ============================================================
print_step "3/5" "Starting all services"

echo ""
echo "  Starting 3 containers:"
echo "    1. sonarqube-db  (PostgreSQL database)"
echo "    2. sonarqube     (code quality scanner)"
echo "    3. jenkins       (CI/CD pipeline server)"
echo ""

docker compose up -d 2>&1 | sed 's/^/  /'

echo ""
print_ok "Containers started"

# Show running containers
echo ""
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | sed 's/^/  /' || docker compose ps | sed 's/^/  /'

# ============================================================
#  STEP 4: Wait for Services to Be Ready
# ============================================================
print_step "4/5" "Waiting for services to be ready"

echo ""
echo "  Jenkins and SonarQube take a bit to start up."
echo "  This is normal — they're loading plugins and initializing."
echo ""

# Wait for SonarQube (usually ready in ~60s)
echo -e "  ${CYAN}--- SonarQube ---${NC}"
if wait_for_url "http://localhost:9000" "SonarQube" 18; then
    print_ok "SonarQube is ready at http://localhost:9000"
else
    print_warn "SonarQube not ready after 3 minutes — it may still be starting."
    print_info "Check manually: docker compose logs sonarqube"
fi

# Wait for Jenkins (usually ready in ~90s)
echo ""
echo -e "  ${CYAN}--- Jenkins ---${NC}"
if wait_for_url "http://localhost:8080" "Jenkins" 24; then
    print_ok "Jenkins is ready at http://localhost:8080"
else
    print_warn "Jenkins not ready after 4 minutes — it may still be starting."
    print_info "Check manually: docker compose logs jenkins"
fi

# ============================================================
#  STEP 5: Print Summary
# ============================================================
print_step "5/5" "Setup Complete!"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  🎉 Everything is running! Here's your info:${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}JENKINS (CI/CD Server):${NC}"
echo -e "    URL:      ${CYAN}http://localhost:8080${NC}"
echo -e "    Username: ${YELLOW}admin${NC}"
echo -e "    Password: ${YELLOW}admin123${NC}"
echo ""
echo -e "  ${BOLD}SONARQUBE (Code Quality):${NC}"
echo -e "    URL:      ${CYAN}http://localhost:9000${NC}"
echo -e "    Username: ${YELLOW}admin${NC}"
echo -e "    Password: ${YELLOW}admin${NC}"
echo -e "    ${YELLOW}(SonarQube will ask you to change the password on first login)${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Useful commands:${NC}"
echo -e "    Stop everything:   ${CYAN}docker compose down${NC}"
echo -e "    See logs:          ${CYAN}docker compose logs -f${NC}"
echo -e "    Jenkins logs only: ${CYAN}docker compose logs -f jenkins${NC}"
echo -e "    Restart:           ${CYAN}docker compose restart${NC}"
echo -e "    Full reset:        ${CYAN}./scripts/teardown.sh${NC}"
echo ""
echo -e "  ${BOLD}Next step:${NC}"
echo -e "    Open ${CYAN}http://localhost:8080${NC} in your browser"
echo -e "    and follow ${CYAN}docs/04-jenkins-pipeline-101.md${NC}"
echo ""
