#!/bin/bash
# Quick wait script for services
for i in $(seq 1 30); do
  JENKINS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 --max-time 3 2>/dev/null)
  SONAR=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9000 --max-time 3 2>/dev/null)
  echo "[$i] Jenkins: $JENKINS | SonarQube: $SONAR"
  if [ "$JENKINS" = "200" ] || [ "$JENKINS" = "302" ] || [ "$JENKINS" = "403" ]; then
    if [ "$SONAR" = "200" ] || [ "$SONAR" = "302" ]; then
      echo ""
      echo "Both services are ready!"
      exit 0
    fi
  fi
  sleep 10
done
echo "Timed out — check docker compose logs"
