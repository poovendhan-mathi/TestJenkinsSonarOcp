#!/bin/bash
# ============================================================
#  STATUS SCRIPT — Check if services are running
# ============================================================
#  Quick check on all your CI/CD services.
#
#  Usage:  ./scripts/status.sh
# ============================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

cd "$(dirname "$0")/.."

echo ""
echo -e "${BOLD}📊 CI/CD Environment Status${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check Docker
if ! docker info > /dev/null 2>&1; then
    echo -e "  ${RED}❌ Docker is NOT running${NC}"
    echo "     Start Docker Desktop first."
    exit 1
fi

# Show containers
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | sed 's/^/  /' || docker compose ps | sed 's/^/  /'

echo ""

# Check Jenkins
JENKINS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080" --max-time 3 2>/dev/null || echo "000")
if [ "$JENKINS_STATUS" = "200" ] || [ "$JENKINS_STATUS" = "302" ] || [ "$JENKINS_STATUS" = "403" ]; then
    echo -e "  ${GREEN}✅ Jenkins:    http://localhost:8080  (Running)${NC}"
else
    echo -e "  ${RED}❌ Jenkins:    http://localhost:8080  (Not responding)${NC}"
fi

# Check SonarQube
SONAR_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:9000" --max-time 3 2>/dev/null || echo "000")
if [ "$SONAR_STATUS" = "200" ] || [ "$SONAR_STATUS" = "302" ]; then
    echo -e "  ${GREEN}✅ SonarQube:  http://localhost:9000  (Running)${NC}"
else
    echo -e "  ${RED}❌ SonarQube:  http://localhost:9000  (Not responding)${NC}"
fi

echo ""
