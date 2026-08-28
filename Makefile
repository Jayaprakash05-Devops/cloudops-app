.PHONY: help build up down restart logs ps clean test lint format security-scan

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Synapse - Cloud Service Health Monitor$(NC)"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

# Docker Compose commands
build: ## Build all services
	@echo "$(BLUE)Building all services...$(NC)"
	docker-compose build

up: ## Start all services
	@echo "$(BLUE)Starting all services...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Services started. Dashboard: http://localhost:3000$(NC)"

down: ## Stop all services
	@echo "$(BLUE)Stopping all services...$(NC)"
	docker-compose down

restart: down up ## Restart all services

logs: ## Show logs from all services
	docker-compose logs -f

ps: ## Show running services
	docker-compose ps

clean: ## Remove all containers, volumes, and images
	@echo "$(YELLOW)Removing all containers, volumes, and images...$(NC)"
	docker-compose down -v --rmi all
	@echo "$(GREEN)Cleanup complete$(NC)"

# Development commands
dev-setup: ## Setup local development environment
	@echo "$(BLUE)Setting up development environment...$(NC)"
	chmod +x scripts/dev-setup.sh
	./scripts/dev-setup.sh

test: ## Run integration tests
	@echo "$(BLUE)Running integration tests...$(NC)"
	chmod +x scripts/test-services.sh
	./scripts/test-services.sh

# Code quality
lint-python: ## Lint Python code
	@echo "$(BLUE)Linting Python code...$(NC)"
	@for service in service-registry health-checker metrics-collector alert-manager; do \
		echo "Linting $$service..."; \
		cd services/$$service && \
		flake8 main.py --max-line-length=120 || true && \
		cd ../..; \
	done

format-python: ## Format Python code with Black
	@echo "$(BLUE)Formatting Python code...$(NC)"
	@for service in service-registry health-checker metrics-collector alert-manager; do \
		echo "Formatting $$service..."; \
		cd services/$$service && \
		black main.py && \
		cd ../..; \
	done

lint-frontend: ## Lint frontend code
	@echo "$(BLUE)Linting frontend code...$(NC)"
	cd frontend && npm run lint || true

# Security
pre-commit-install: ## Install pre-commit hooks
	@echo "$(BLUE)Installing pre-commit hooks...$(NC)"
	pip install pre-commit
	pre-commit install
	pre-commit install --hook-type commit-msg
	@echo "$(GREEN)Pre-commit hooks installed$(NC)"

pre-commit-run: ## Run pre-commit checks on all files
	@echo "$(BLUE)Running pre-commit checks...$(NC)"
	pre-commit run --all-files

security-scan-python: ## Run security scan on Python dependencies
	@echo "$(BLUE)Running comprehensive security scan on Python services...$(NC)"
	@for service in service-registry health-checker metrics-collector alert-manager; do \
		echo ""; \
		echo "$(YELLOW)Scanning $$service...$(NC)"; \
		cd services/$$service && \
		pip install safety pip-audit bandit semgrep 2>/dev/null || true && \
		echo "→ Safety check:"; \
		safety check || true && \
		echo "→ pip-audit:"; \
		pip-audit || true && \
		echo "→ Bandit SAST:"; \
		bandit -r main.py || true && \
		echo "→ Semgrep:"; \
		semgrep --config=auto main.py || true && \
		cd ../..; \
	done

security-scan-frontend: ## Run security scan on frontend dependencies
	@echo "$(BLUE)Running comprehensive security scan on frontend...$(NC)"
	cd frontend && \
	echo "→ npm audit:" && npm audit || true && \
	echo "→ RetireJS:" && npx retire --js --node || true && \
	echo "→ License check:" && npx license-checker --summary || true

security-secrets-scan: ## Scan for secrets in code
	@echo "$(BLUE)Scanning for secrets...$(NC)"
	pip install detect-secrets 2>/dev/null || true
	detect-secrets scan || true
	@echo ""
	pip install truffleHog 2>/dev/null || true
	trufflehog filesystem . --only-verified || true

security-container-scan: ## Scan containers for vulnerabilities
	@echo "$(BLUE)Scanning container images...$(NC)"
	@echo "Building images..."
	@docker-compose build --quiet
	@echo ""
	@for service in service-registry health-checker metrics-collector alert-manager; do \
		echo "$(YELLOW)Scanning synapse-$$service...$(NC)"; \
		trivy image synapse-$$service:latest || true; \
		echo ""; \
	done
	@echo "$(YELLOW)Scanning frontend...$(NC)"
	@trivy image synapse-frontend:latest || true

security-iac-scan: ## Scan Infrastructure as Code
	@echo "$(BLUE)Scanning IaC (Dockerfiles, docker-compose)...$(NC)"
	pip install checkov 2>/dev/null || true
	@echo "→ Checking Dockerfiles:"
	@find . -name "Dockerfile" -exec checkov -f {} \; || true
	@echo ""
	@echo "→ Checking docker-compose.yml:"
	@checkov -f docker-compose.yml || true

security-sbom: ## Generate Software Bill of Materials
	@echo "$(BLUE)Generating SBOMs...$(NC)"
	@mkdir -p reports/sbom
	@for service in service-registry health-checker metrics-collector alert-manager; do \
		echo "→ SBOM for $$service"; \
		cd services/$$service && \
		pip install cyclonedx-bom 2>/dev/null || true && \
		cyclonedx-py -r -i requirements.txt -o ../../reports/sbom/$$service-sbom.json && \
		cd ../..; \
	done
	@echo "→ SBOM for frontend"
	@cd frontend && \
	npm install -g @cyclonedx/cyclonedx-npm 2>/dev/null || true && \
	cyclonedx-npm --output-file ../reports/sbom/frontend-sbom.json
	@echo "$(GREEN)SBOMs generated in reports/sbom/$(NC)"

security-report: ## Generate comprehensive security report
	@echo "$(BLUE)Generating security report...$(NC)"
	@mkdir -p reports
	@echo "# Security Report - Generated $(shell date)" > reports/security-report.md
	@echo "" >> reports/security-report.md
	@echo "## Dependency Vulnerabilities" >> reports/security-report.md
	@echo "### Python Services" >> reports/security-report.md
	@for service in service-registry health-checker metrics-collector alert-manager; do \
		echo "#### $$service" >> reports/security-report.md; \
		cd services/$$service && safety check --json >> ../../reports/security-report.md 2>&1 || true && cd ../..; \
	done
	@echo "### Frontend" >> reports/security-report.md
	@cd frontend && npm audit --json >> ../reports/security-report.md 2>&1 || true
	@echo "$(GREEN)Report generated: reports/security-report.md$(NC)"

security-full: security-secrets-scan security-scan-python security-scan-frontend security-iac-scan security-container-scan ## Run all security scans

security-scan: security-full ## Alias for security-full

# Container operations
shell-registry: ## Open shell in service-registry container
	docker-compose exec service-registry sh

shell-health: ## Open shell in health-checker container
	docker-compose exec health-checker sh

shell-metrics: ## Open shell in metrics-collector container
	docker-compose exec metrics-collector sh

shell-alerts: ## Open shell in alert-manager container
	docker-compose exec alert-manager sh

shell-frontend: ## Open shell in frontend container
	docker-compose exec frontend sh

shell-redis: ## Open Redis CLI
	docker-compose exec redis redis-cli

# Health checks
health-check: ## Check health of all services
	@echo "$(BLUE)Checking service health...$(NC)"
	@for port in 8001 8002 8003 8004 3000; do \
		if curl -f -s http://localhost:$$port/health > /dev/null 2>&1; then \
			echo "$(GREEN)✓ Port $$port is healthy$(NC)"; \
		else \
			echo "$(YELLOW)✗ Port $$port is not responding$(NC)"; \
		fi; \
	done

# Documentation
docs: ## Open documentation in browser
	@echo "$(BLUE)Opening documentation...$(NC)"
	@open README.md || xdg-open README.md || echo "Please open README.md manually"

api-docs: up ## Open API documentation in browser
	@echo "$(BLUE)Opening API documentation...$(NC)"
	@sleep 2
	@open http://localhost:8001/docs || xdg-open http://localhost:8001/docs

# Monitoring
dashboard: up ## Open dashboard in browser
	@echo "$(BLUE)Opening dashboard...$(NC)"
	@sleep 5
	@open http://localhost:3000 || xdg-open http://localhost:3000

# Data operations
redis-flush: ## Flush all Redis data
	@echo "$(YELLOW)Flushing Redis data...$(NC)"
	docker-compose exec redis redis-cli FLUSHALL
	@echo "$(GREEN)Redis data cleared$(NC)"

# CI/CD local testing
ci-test: ## Test CI/CD workflows locally (requires 'act')
	@echo "$(BLUE)Testing CI/CD workflows locally...$(NC)"
	@if command -v act > /dev/null; then \
		act -W .github/workflows/service-registry.yml; \
	else \
		echo "$(YELLOW)Please install 'act' to test workflows locally$(NC)"; \
		echo "https://github.com/nektos/act"; \
	fi

# Deployment
deploy-dev: build up ## Deploy to development environment
	@echo "$(GREEN)Deployed to development environment$(NC)"
	@echo "Dashboard: http://localhost:3000"

# Utilities
install-tools: ## Install development tools
	@echo "$(BLUE)Installing development tools...$(NC)"
	pip install black flake8 pylint bandit safety pytest pytest-cov || true
	@echo "$(GREEN)Tools installed$(NC)"

version: ## Show version information
	@echo "$(BLUE)Synapse Version Information$(NC)"
	@echo "Python: $$(python3 --version 2>&1)"
	@echo "Node: $$(node --version 2>&1)"
	@echo "Docker: $$(docker --version 2>&1)"
	@echo "Docker Compose: $$(docker-compose --version 2>&1)"

# Quick start
quick-start: build up health-check dashboard ## Quick start: build, start, check, and open dashboard
	@echo "$(GREEN)Synapse is ready!$(NC)"

# Default target
.DEFAULT_GOAL := help
