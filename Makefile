.PHONY: help start stop restart logs backup restore clean test deploy-dev deploy-prod validate

.DEFAULT_GOAL := help

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

start: ## Start monitoring stack
	@echo "Starting monitoring stack..."
	docker-compose up -d
	@echo "Monitoring stack started successfully!"
	@echo "Access services:"
	@echo "  - Grafana: http://localhost:3000 (admin/admin)"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - Alertmanager: http://localhost:9093"
	@echo "  - Loki: http://localhost:3100"

stop: ## Stop monitoring stack
	@echo "Stopping monitoring stack..."
	docker-compose down
	@echo "Monitoring stack stopped."

restart: ## Restart monitoring stack
	@echo "Restarting monitoring stack..."
	docker-compose restart
	@echo "Monitoring stack restarted."

logs: ## Show logs from all services
	docker-compose logs -f

logs-grafana: ## Show Grafana logs
	docker-compose logs -f grafana

logs-prometheus: ## Show Prometheus logs
	docker-compose logs -f prometheus

logs-loki: ## Show Loki logs
	docker-compose logs -f loki

status: ## Show status of all services
	@docker-compose ps

validate: ## Validate configuration files
	@echo "Validating docker-compose configuration..."
	@docker-compose config > /dev/null && echo "✓ docker-compose.yml is valid"
	@docker-compose -f docker-compose.dev.yml config > /dev/null && echo "✓ docker-compose.dev.yml is valid"
	@docker-compose -f docker-compose.prod.yml config > /dev/null && echo "✓ docker-compose.prod.yml is valid"
	@echo "Validating Prometheus configuration..."
	@docker run --rm -v $(PWD)/prometheus:/prometheus prom/prometheus:latest promtool check config /prometheus/prometheus.yml && echo "✓ prometheus.yml is valid"
	@docker run --rm -v $(PWD)/prometheus:/prometheus prom/prometheus:latest promtool check rules /prometheus/alerts/monitoring.yml && echo "✓ monitoring.yml is valid"

backup: ## Backup Grafana dashboards and Prometheus data
	@echo "Creating backup..."
	@./scripts/backup.sh

restore: ## Restore from backup
	@echo "Restoring from backup..."
	@./scripts/restore.sh

clean: ## Remove all containers and volumes
	@echo "Warning: This will remove all containers and volumes!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "Cleanup complete."; \
	else \
		echo "Cleanup cancelled."; \
	fi

deploy-dev: ## Deploy to dev environment
	@echo "Deploying to development environment..."
	docker-compose -f docker-compose.dev.yml up -d
	@echo "Development environment deployed!"

deploy-prod: ## Deploy to production
	@echo "Deploying to production environment..."
	docker-compose -f docker-compose.prod.yml up -d
	@echo "Production environment deployed!"

test: ## Run tests
	@echo "Running tests..."
	@./scripts/test.sh

pull: ## Pull latest images
	@echo "Pulling latest images..."
	docker-compose pull

update: pull restart ## Update and restart services

ps: ## Show running containers
	@docker-compose ps

shell-grafana: ## Open shell in Grafana container
	@docker-compose exec grafana /bin/sh

shell-prometheus: ## Open shell in Prometheus container
	@docker-compose exec prometheus /bin/sh

reload-prometheus: ## Reload Prometheus configuration
	@echo "Reloading Prometheus configuration..."
	@curl -X POST http://localhost:9090/-/reload
	@echo "Prometheus configuration reloaded."

health: ## Check health of all services
	@echo "Checking service health..."
	@echo -n "Grafana: "
	@curl -f -s http://localhost:3000/api/health > /dev/null && echo "✓ OK" || echo "✗ FAIL"
	@echo -n "Prometheus: "
	@curl -f -s http://localhost:9090/-/healthy > /dev/null && echo "✓ OK" || echo "✗ FAIL"
	@echo -n "Alertmanager: "
	@curl -f -s http://localhost:9093/-/healthy > /dev/null && echo "✓ OK" || echo "✗ FAIL"
	@echo -n "Loki: "
	@curl -f -s http://localhost:3100/ready > /dev/null && echo "✓ OK" || echo "✗ FAIL"
