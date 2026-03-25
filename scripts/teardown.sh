#!/bin/bash
# ============================================================
#  TEARDOWN SCRIPT — Stop & Clean Up Everything
# ============================================================
#  This script stops containers and optionally removes all data.
#
#  Usage:
#    ./scripts/teardown.sh          ← Stop containers (keep data)
#    ./scripts/teardown.sh --full   ← Stop containers AND delete all data
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

cd "$(dirname "$0")/.."  # Go to project root

echo ""
echo -e "${BOLD}🛑 Shutting down CI/CD environment...${NC}"
echo ""

if [ "$1" = "--full" ]; then
    echo -e "${YELLOW}⚠️  FULL CLEANUP: This will delete ALL data (Jenkins jobs, SonarQube projects, etc.)${NC}"
    echo ""
    read -p "  Are you sure? Type 'yes' to confirm: " confirm
    if [ "$confirm" != "yes" ]; then
        echo "  Cancelled."
        exit 0
    fi

    echo ""
    echo "  Stopping containers and removing volumes..."
    docker compose down -v 2>&1 | sed 's/^/  /'
    echo ""
    echo -e "${GREEN}✅ Everything stopped and all data deleted.${NC}"
    echo -e "   Run ${CYAN}./scripts/setup.sh${NC} to start fresh."
else
    echo "  Stopping containers (keeping data for next time)..."
    docker compose down 2>&1 | sed 's/^/  /'
    echo ""
    echo -e "${GREEN}✅ Containers stopped. Your data is saved.${NC}"
    echo -e "   Run ${CYAN}docker compose up -d${NC} or ${CYAN}./scripts/setup.sh${NC} to start again."
    echo ""
    echo -e "   To delete everything: ${CYAN}./scripts/teardown.sh --full${NC}"
fi

echo ""
