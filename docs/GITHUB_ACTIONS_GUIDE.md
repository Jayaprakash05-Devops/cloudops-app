# GitHub Actions CI/CD Pipeline Guide

## 🎯 Overview

CloudOps Command Center uses a comprehensive 8-stage security-first CI/CD pipeline for all services.

## 🏗️ Architecture

### Reusable Workflows
- **`reusable-backend-ci.yml`** - Template for all backend services
- **Individual service workflows** - Call the reusable workflow with service-specific parameters

### Service Workflows
1. `cost-optimizer-ci.yml` - Port 8001
2. `k8s-manager-ci.yml` - Port 8002
3. `incident-manager-ci.yml` - Port 8003
4. `automation-service-ci.yml` - Port 8004
5. `chatops-bot-ci.yml` - Port 8005
6. `metrics-collector-ci.yml` - Port 8006
7. `frontend-ci.yml` - Port 3000
8. `platform-ci.yml` - Full platform integration test

## 📊 8-Stage Security Pipeline

### Stage 1: 🔍 Validate
**Purpose:** Prevent secrets from being committed

**Tools:**
- TruffleHog - 700+ secret patterns
- GitLeaks - 140+ patterns

**What it catches:**
- API keys, tokens
- AWS/GCP/Azure credentials
- Database passwords
- Private keys

### Stage 2: 📦 Dependencies
**Purpose:** Scan dependencies for known vulnerabilities

**Backend Tools:**
- Safety - PyUp.io vulnerability database
- pip-audit - OSV + PyPI Advisory Database
- CycloneDX - SBOM generation

**Frontend Tools:**
- npm audit - npm registry vulnerabilities
- CycloneDX - SBOM generation

**Outputs:**
- `safety-report.json`
- `pip-audit-report.json`
- `npm-audit-report.json`
- `sbom.json` (uploaded as artifact)

### Stage 3: 🎨 Code Quality
**Purpose:** Ensure code quality and maintainability

**Backend Tools:**
- Black - Code formatting
- Flake8 - PEP8 compliance
- Pylint - Static analysis
- mypy - Type checking
- isort - Import sorting
- Radon - Complexity metrics

**Frontend Tools:**
- ESLint - JavaScript linting
- Prettier - Code formatting

**Outputs:**
- `flake8-report.json`
- `pylint-report.json`
- `radon-cc.json` (cyclomatic complexity)
- `radon-mi.json` (maintainability index)
- `eslint-report.json`

### Stage 4: 🔒 Security (SAST)
**Purpose:** Static application security testing

**Tools:**
- Bandit - Python security issues
- Semgrep - Multi-language security patterns

**What it detects:**
- SQL injection
- Command injection
- XSS vulnerabilities
- Path traversal
- Weak cryptography
- Unsafe deserialization

**Outputs:**
- `bandit-report.json`
- `bandit.sarif` (uploaded to GitHub Security)
- `semgrep-report.json`

### Stage 5: 🔨 Build
**Purpose:** Build Docker images with caching

**Features:**
- Multi-stage Docker builds
- BuildKit caching (GitHub Actions cache)
- Non-root user execution
- Health checks included

**Outputs:**
- Docker image saved as artifact (tar file)
- Build cache stored in GitHub Actions cache

### Stage 6: 🐳 Container Scan
**Purpose:** Scan container images for vulnerabilities

**Tool:** Trivy

**What it scans:**
- OS vulnerabilities (Alpine, Debian, etc.)
- Application dependencies
- Misconfigurations
- Exposed secrets

**Databases:**
- NVD (National Vulnerability Database)
- CVE
- GHSA (GitHub Security Advisories)

**Outputs:**
- `trivy-image-results.sarif` (uploaded to GitHub Security)
- `trivy-image-results.json`

### Stage 7: 🧪 Test
**Purpose:** Functional testing of services

**What it tests:**
- Service startup
- Health endpoint (`/health`)
- Basic API endpoints
- Service dependencies (Redis)

**Process:**
1. Start Redis container
2. Start service container
3. Wait for health check
4. Test endpoints
5. Verify responses
6. Collect logs on failure

### Stage 8: 📊 Report
**Purpose:** Aggregate results and generate reports

**Features:**
- Downloads all artifacts
- Generates GitHub Actions summary
- Lists all completed stages
- Links to SARIF reports in GitHub Security tab

## 🚀 Workflow Triggers

### Individual Service Workflows
Trigger when:
- Push to service directory (`services/cost-optimizer/**`)
- Pull request affecting service
- Workflow file changes

### Platform Workflow
Triggers on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`

**Runs:**
- All 6 backend service pipelines (parallel)
- Frontend pipeline (parallel)
- Integration tests (after all pass)
- Platform report generation

## 📦 Artifacts Generated

### Per Service
1. **SBOM** - Software Bill of Materials (CycloneDX format)
2. **Dependency Reports** - Vulnerability scan results
3. **Quality Reports** - Code quality metrics
4. **Security Reports** - SAST findings
5. **Container Reports** - Trivy scan results
6. **Docker Image** - Built and tested image (1-day retention)

### Platform Level
- **All Reports** - Aggregated reports from all services
- **Integration Test Results** - Cross-service test results

## 🔐 GitHub Security Integration

### SARIF Upload
The following reports are uploaded to GitHub Security tab:
- Bandit (Python SAST) - per service
- Trivy (Container scan) - per service

**View in GitHub:**
1. Go to repository **Security** tab
2. Click **Code scanning alerts**
3. Filter by tool (Bandit, Trivy)
4. View findings by service

## 🎯 How to Use

### For a Single Service
```bash
# Trigger manually (GitHub Actions UI)
Actions → [Service Name] CI → Run workflow

# Or push changes to service directory
git add services/cost-optimizer/
git commit -m "Update cost optimizer"
git push
```

### For Full Platform
```bash
# Push to main/develop branch
git checkout main
git add .
git commit -m "Platform update"
git push origin main
```

### View Results
1. Go to **Actions** tab in GitHub
2. Click on workflow run
3. See the 8 stages with checkmarks
4. Click **Summary** for detailed report
5. Download artifacts if needed
6. Check **Security** tab for SARIF findings

## 📊 Workflow Status Badges

Add to README.md:

```markdown
![Cost Optimizer CI](https://github.com/YOUR_USERNAME/Synapse/workflows/Cost%20Optimizer%20CI/badge.svg)
![Platform CI](https://github.com/YOUR_USERNAME/Synapse/workflows/Platform%20CI%2FCD/badge.svg)
```

## 🔧 Configuration

### Secrets Required
None! All tools are free and open-source.

### Optional Secrets
- `SNYK_TOKEN` - For Snyk dependency scanning (freemium)
- `SONAR_TOKEN` - For SonarQube analysis (freemium)

## 🎓 Best Practices

### 1. Run Locally First
```bash
# Test service locally before pushing
cd services/cost-optimizer
python main.py
curl http://localhost:8001/health
```

### 2. Check Pre-commit Hooks
```bash
# Install pre-commit
pip install pre-commit
pre-commit install

# Run manually
pre-commit run --all-files
```

### 3. Review Security Findings
- Check GitHub Security tab after pipeline runs
- Address critical/high severity issues first
- Review false positives

### 4. Monitor Build Times
- Backend services: ~5-10 minutes
- Frontend: ~8-12 minutes
- Full platform: ~15-20 minutes

## 🐛 Troubleshooting

### Build Failures

**Dependency Stage Fails:**
```bash
# Update requirements.txt locally
pip install -r requirements.txt
pip freeze > requirements.txt
```

**Docker Build Fails:**
```bash
# Test Docker build locally
docker build -t test-image services/cost-optimizer/
```

**Tests Fail:**
```bash
# Check health endpoint locally
docker run -p 8001:8001 test-image
curl http://localhost:8001/health
```

### View Workflow Logs
1. Click on failed workflow run
2. Click on failed stage
3. Expand log sections
4. Look for error messages

### Re-run Failed Workflows
1. Go to failed workflow run
2. Click "Re-run jobs"
3. Select "Re-run failed jobs"

## 📈 Performance Optimization

### Caching
- **pip dependencies** - Cached by Python setup action
- **npm packages** - Cached by Node setup action
- **Docker layers** - BuildKit cache in GitHub Actions cache

### Parallel Execution
- All 6 backend services run in parallel
- Frontend runs in parallel with backend
- Only integration tests run sequentially (needs all services)

### Artifact Retention
- Docker images: 1 day (saves storage)
- Reports: 90 days (GitHub default)
- Adjust in workflow if needed

## 🎉 Summary

**Total Workflows:** 8
- 6 backend service workflows
- 1 frontend workflow
- 1 platform workflow

**Total Stages:** 8 per service
1. Validate → 2. Dependencies → 3. Code Quality → 4. Security → 5. Build → 6. Container Scan → 7. Test → 8. Report

**Security Tools:** 15+
- Secrets: TruffleHog, GitLeaks
- Dependencies: Safety, pip-audit, npm audit
- Code Quality: Black, Flake8, Pylint, Radon, ESLint
- SAST: Bandit, Semgrep
- Container: Trivy
- SBOM: CycloneDX

**Cost:** $0/month (all free tools, GitHub Actions free tier: 2000 minutes/month)

---

🎯 **Your CI/CD pipeline is now production-ready!**
