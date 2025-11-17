#!/bin/bash

# Quick start script for StatsVM-Grafana
# This script helps you get started quickly with the monitoring stack

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║   StatsVM-Grafana Quick Start                  ║"
    echo "║   Modern Monitoring Stack                      ║"
    echo "╚════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_dependencies() {
    echo "Checking dependencies..."
    
    local missing_deps=0
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_success "Docker is installed ($(docker --version))"
    else
        print_error "Docker is not installed"
        missing_deps=1
    fi
    
    # Check Docker Compose
    if docker compose version &> /dev/null; then
        print_success "Docker Compose is installed ($(docker compose version))"
    elif command -v docker-compose &> /dev/null; then
        print_success "Docker Compose is installed ($(docker-compose --version))"
    else
        print_error "Docker Compose is not installed"
        missing_deps=1
    fi
    
    if [ $missing_deps -eq 1 ]; then
        echo ""
        print_error "Missing dependencies. Please install:"
        echo "  - Docker: https://docs.docker.com/get-docker/"
        echo "  - Docker Compose: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    echo ""
}

setup_environment() {
    echo "Setting up environment..."
    
    if [ ! -f .env ]; then
        print_info "Creating .env file from template"
        cp .env.example .env
        print_success ".env file created"
        print_info "Edit .env file to customize settings"
    else
        print_info ".env file already exists"
    fi
    
    echo ""
}

validate_configs() {
    echo "Validating configurations..."
    
    if docker compose config > /dev/null 2>&1; then
        print_success "Docker Compose configuration is valid"
    else
        print_error "Docker Compose configuration has errors"
        docker compose config
        exit 1
    fi
    
    echo ""
}

start_stack() {
    echo "Starting monitoring stack..."
    echo "This may take a few minutes on first run (downloading images)..."
    echo ""
    
    docker compose up -d
    
    echo ""
    print_success "Monitoring stack started!"
    echo ""
}

wait_for_services() {
    echo "Waiting for services to be ready..."
    echo "This usually takes 30-60 seconds..."
    echo ""
    
    sleep 30
    
    local max_attempts=12
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -f -s http://localhost:3000/api/health > /dev/null 2>&1 && \
           curl -f -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
            print_success "All services are ready!"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo "Waiting... (attempt $attempt/$max_attempts)"
        sleep 5
    done
    
    print_error "Services did not start properly. Check logs with: docker compose logs"
    return 1
}

print_access_info() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  🎉 Setup Complete!                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Access your services:"
    echo ""
    echo -e "  🎨 Grafana:          ${BLUE}http://localhost:3000${NC}"
    echo "     Username: admin"
    echo "     Password: admin (change this!)"
    echo ""
    echo -e "  📊 Prometheus:       ${BLUE}http://localhost:9090${NC}"
    echo -e "  🔔 Alertmanager:     ${BLUE}http://localhost:9093${NC}"
    echo -e "  📝 Loki:             ${BLUE}http://localhost:3100${NC}"
    echo ""
    echo "Useful commands:"
    echo "  make help          - Show all available commands"
    echo "  make logs          - Show service logs"
    echo "  make stop          - Stop all services"
    echo "  make restart       - Restart services"
    echo "  make health        - Check service health"
    echo ""
    echo "Documentation:"
    echo "  README.md          - Main documentation"
    echo "  MIGRATION_GUIDE.md - Migration from old setup"
    echo "  CONTRIBUTING.md    - Contribution guidelines"
    echo ""
}

show_next_steps() {
    echo "Next steps:"
    echo ""
    echo "1. Log into Grafana and change the admin password"
    echo "2. Explore the pre-configured dashboards"
    echo "3. Check Prometheus targets: http://localhost:9090/targets"
    echo "4. Configure alerting in prometheus/alerts/"
    echo "5. Set up backups with: make backup"
    echo ""
    echo "For more information, see README.md"
    echo ""
}

main() {
    print_header
    
    check_dependencies
    setup_environment
    validate_configs
    start_stack
    
    if wait_for_services; then
        print_access_info
        show_next_steps
    else
        echo ""
        print_error "Setup completed with errors"
        echo "Check logs with: docker compose logs"
        echo "Or get help: make help"
        exit 1
    fi
}

# Run main function
main
