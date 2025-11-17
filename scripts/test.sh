#!/bin/bash

# Test script for monitoring stack
# This script validates that all services are running and accessible

set -e

echo "Running monitoring stack tests..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

test_service() {
    local service=$1
    local url=$2
    local expected_code=${3:-200}
    
    echo -n "Testing $service... "
    
    if curl -f -s -o /dev/null -w "%{http_code}" "$url" | grep -q "$expected_code"; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

test_container() {
    local container=$1
    
    echo -n "Testing $container container... "
    
    if docker ps | grep -q "$container"; then
        echo -e "${GREEN}✓ RUNNING${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ NOT RUNNING${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 10

echo ""
echo "=== Container Status Tests ==="
test_container "grafana"
test_container "prometheus"
test_container "loki"
test_container "node-exporter"
test_container "promtail"
test_container "alertmanager"

echo ""
echo "=== Service Health Tests ==="
test_service "Grafana" "http://localhost:3000/api/health"
test_service "Prometheus" "http://localhost:9090/-/healthy"
test_service "Prometheus API" "http://localhost:9090/api/v1/status/config"
test_service "Alertmanager" "http://localhost:9093/-/healthy"
test_service "Loki" "http://localhost:3100/ready"

echo ""
echo "=== Prometheus Metrics Tests ==="
test_service "Node Exporter Metrics" "http://localhost:9100/metrics"

echo ""
echo "=== Configuration Tests ==="
echo -n "Testing Prometheus config... "
if docker exec prometheus promtool check config /etc/prometheus/prometheus.yml &>/dev/null; then
    echo -e "${GREEN}✓ VALID${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ INVALID${NC}"
    FAILED=$((FAILED + 1))
fi

echo -n "Testing Prometheus rules... "
if docker exec prometheus promtool check rules /etc/prometheus/alerts/monitoring.yml &>/dev/null; then
    echo -e "${GREEN}✓ VALID${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ INVALID${NC}"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "=== Data Source Tests ==="
echo -n "Testing Prometheus datasource in Grafana... "
if curl -s http://localhost:3000/api/datasources | grep -q "Prometheus"; then
    echo -e "${GREEN}✓ CONFIGURED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠ NOT CONFIGURED${NC}"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "=== Summary ==="
echo "Tests passed: ${GREEN}$PASSED${NC}"
echo "Tests failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed!${NC}"
    exit 1
fi
