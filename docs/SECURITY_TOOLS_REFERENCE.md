# Security Tools Reference Guide

This document lists all security tools integrated into the Synapse CI/CD pipeline, organized by category.

## 📊 Overview

**Total Tools**: 34 (16 backend + 18 frontend)
**Categories**: 7 (Secrets, Dependencies, Code Quality, SAST, IaC, Containers, Performance)

---

## 🔐 Category 1: Secret Detection (3 tools)

### 1.1 TruffleHog
- **Type**: Secret detection
- **Language**: Multi-language
- **What it detects**: 
  - API keys and tokens
  - AWS/GCP/Azure credentials
  - Private keys
  - Database passwords
  - OAuth tokens
  - 700+ credential patterns
- **Integration**: 
  - Pre-commit hook
  - CI/CD validate stage
- **GitHub**: https://github.com/trufflesecurity/trufflehog
- **Config**: `.pre-commit-config.yaml`

### 1.2 GitLeaks
- **Type**: Secret detection
- **Language**: Multi-language
- **What it detects**:
  - Hardcoded secrets
  - Credentials in git history
  - API keys
  - Private keys
  - 140+ patterns
- **Integration**:
  - Pre-commit hook
  - CI/CD validate stage
  - GitHub Action
- **GitHub**: https://github.com/gitleaks/gitleaks
- **Config**: `.pre-commit-config.yaml`

### 1.3 detect-secrets
- **Type**: Secret detection
- **Language**: Multi-language
- **What it detects**:
  - High entropy strings
  - Base64 encoded secrets
  - AWS keys
  - Private keys
  - Slack tokens
- **Integration**:
  - Pre-commit hook
  - Makefile command
- **GitHub**: https://github.com/Yelp/detect-secrets
- **Config**: `.pre-commit-config.yaml`, `.secrets.baseline`

---

## 📦 Category 2: Dependency Security (10 tools)

### 2.1 Safety (Python)
- **Type**: SCA (Software Composition Analysis)
- **Language**: Python
- **Database**: PyUp.io vulnerability database (40,000+ known vulnerabilities)
- **What it checks**:
  - Python package vulnerabilities
  - CVE database
  - Security advisories
- **Integration**:
  - CI/CD dependency stage
  - Makefile command
- **Output**: `safety-report.json`
- **GitHub**: https://github.com/pyupio/safety
- **Command**: `safety check --json`

### 2.2 pip-audit (Python)
- **Type**: SCA
- **Language**: Python
- **Database**: OSV, PyPI Advisory Database
- **What it checks**:
  - Python dependencies
  - CVE cross-reference
  - Vulnerability reports
- **Integration**: CI/CD dependency stage
- **Output**: `pip-audit-report.json`
- **GitHub**: https://github.com/pypa/pip-audit
- **Command**: `pip-audit --desc`

### 2.3 npm audit (JavaScript)
- **Type**: SCA
- **Language**: JavaScript/Node.js
- **Database**: npm registry vulnerability database
- **What it checks**:
  - npm package vulnerabilities
  - Transitive dependencies
  - Known security advisories
- **Integration**: CI/CD dependency stage
- **Output**: `npm-audit-report.json`
- **Command**: `npm audit --json`

### 2.4 Snyk (JavaScript)
- **Type**: SCA (Commercial)
- **Language**: Multi-language (JS focus here)
- **Database**: Snyk vulnerability DB (proprietary)
- **What it checks**:
  - Open source vulnerabilities
  - License compliance
  - Container vulnerabilities
  - IaC issues
- **Integration**: CI/CD dependency stage
- **Output**: `snyk-report.json`
- **Website**: https://snyk.io
- **Command**: `snyk test --json`
- **Note**: Requires `SNYK_TOKEN` secret

### 2.5 RetireJS (JavaScript)
- **Type**: SCA
- **Language**: JavaScript
- **Database**: Retire.js vulnerability database
- **What it checks**:
  - Outdated JavaScript libraries
  - Known vulnerable versions
  - Client-side libraries
- **Integration**: CI/CD dependency stage
- **Output**: `retire-report.json`
- **GitHub**: https://github.com/RetireJS/retire.js
- **Command**: `retire --js --node`

### 2.6 OWASP Dependency-Check
- **Type**: SCA
- **Language**: Multi-language
- **Database**: NVD (National Vulnerability Database)
- **What it checks**:
  - All project dependencies
  - CVE database
  - CPE (Common Platform Enumeration)
- **Integration**: CI/CD security scan stage
- **Output**: `dependency-check-report/`
- **Website**: https://owasp.org/www-project-dependency-check/
- **Command**: `dependency-check.sh --scan . --format JSON`

### 2.7 license-checker (JavaScript)
- **Type**: License compliance
- **Language**: JavaScript/Node.js
- **What it checks**:
  - All package licenses
  - License compatibility
  - Problematic licenses (GPL, AGPL)
- **Integration**: CI/CD dependency stage
- **Output**: `licenses.json`
- **GitHub**: https://github.com/davglass/license-checker
- **Command**: `license-checker --json`

### 2.8 CycloneDX (Python)
- **Type**: SBOM (Software Bill of Materials) Generator
- **Language**: Python
- **Format**: CycloneDX (OWASP standard)
- **What it generates**:
  - Complete dependency list
  - Version information
  - License data
  - Vulnerability mapping
- **Integration**: CI/CD dependency stage
- **Output**: `sbom.json`
- **Website**: https://cyclonedx.org
- **Command**: `cyclonedx-py -r -i requirements.txt -o sbom.json`

### 2.9 CycloneDX (JavaScript)
- **Type**: SBOM Generator
- **Language**: JavaScript/Node.js
- **Format**: CycloneDX
- **What it generates**:
  - npm dependency tree
  - Version information
  - License data
- **Integration**: CI/CD dependency stage
- **Output**: `sbom.json`
- **Command**: `cyclonedx-npm --output-file sbom.json`

### 2.10 Dependabot
- **Type**: Automated dependency updates
- **Language**: Multi-language
- **What it does**:
  - Weekly dependency scans
  - Automatic PR creation
  - Security update prioritization
- **Integration**: `.github/dependabot.yml`
- **Scans**: Python, JavaScript, Docker, GitHub Actions
- **Website**: GitHub native feature

---

## 🎨 Category 3: Code Quality (12 tools)

### 3.1 Black (Python)
- **Type**: Code formatter
- **Language**: Python
- **What it does**: Enforces consistent code style
- **Integration**: Pre-commit, CI/CD
- **Config**: `.pre-commit-config.yaml`
- **Command**: `black --check main.py`

### 3.2 Flake8 (Python)
- **Type**: Linter
- **Language**: Python
- **What it checks**: PEP8 compliance, syntax errors
- **Integration**: Pre-commit, CI/CD
- **Output**: `flake8-report.json`
- **Command**: `flake8 --max-line-length=120`

### 3.3 Pylint (Python)
- **Type**: Static analyzer
- **Language**: Python
- **What it checks**: Code quality, bugs, style
- **Integration**: CI/CD code quality stage
- **Output**: `pylint-report.json`
- **Command**: `pylint main.py --reports=y`

### 3.4 mypy (Python)
- **Type**: Type checker
- **Language**: Python
- **What it checks**: Type hints, type safety
- **Integration**: Pre-commit, CI/CD
- **Command**: `mypy main.py --strict`

### 3.5 isort (Python)
- **Type**: Import sorter
- **Language**: Python
- **What it does**: Organizes imports
- **Integration**: Pre-commit, CI/CD
- **Command**: `isort --check-only main.py`

### 3.6 Radon (Python)
- **Type**: Complexity analyzer
- **Language**: Python
- **What it measures**:
  - Cyclomatic complexity
  - Maintainability index
  - Raw metrics (LOC, comments)
- **Integration**: CI/CD code quality stage
- **Output**: `radon-cc.json`, `radon-mi.json`, `radon-raw.json`
- **Command**: `radon cc main.py -s -a`

### 3.7 ESLint (JavaScript)
- **Type**: Linter
- **Language**: JavaScript/TypeScript
- **What it checks**: Code quality, best practices
- **Integration**: Pre-commit, CI/CD
- **Output**: `eslint-report.json`
- **Config**: `.eslintrc`
- **Command**: `eslint src/ --format json`

### 3.8 Prettier (JavaScript)
- **Type**: Code formatter
- **Language**: JavaScript/TypeScript/JSON/CSS
- **What it does**: Enforces consistent style
- **Integration**: Pre-commit, CI/CD
- **Config**: `.prettierrc`
- **Command**: `prettier --check "src/**/*.js"`

### 3.9 complexity-report (JavaScript)
- **Type**: Complexity analyzer
- **Language**: JavaScript
- **What it measures**: Cyclomatic complexity
- **Integration**: CI/CD code quality stage
- **Output**: `complexity-report.json`
- **Command**: `cr src/**/*.js`

### 3.10 jscpd (JavaScript)
- **Type**: Copy-paste detector
- **Language**: JavaScript
- **What it detects**: Code duplication
- **Integration**: CI/CD code quality stage
- **Output**: `jscpd-report.json`
- **Command**: `jscpd src/`

### 3.11 TypeScript Compiler (if applicable)
- **Type**: Type checker
- **Language**: TypeScript
- **What it checks**: Type safety, compilation errors
- **Integration**: CI/CD (if tsconfig.json exists)
- **Command**: `tsc --noEmit`

### 3.12 hadolint (Dockerfile)
- **Type**: Dockerfile linter
- **Language**: Dockerfile
- **What it checks**: Best practices, security issues
- **Integration**: Pre-commit hook
- **GitHub**: https://github.com/hadolint/hadolint
- **Command**: `hadolint Dockerfile`

---

## 🔒 Category 4: SAST (Static Application Security Testing) (4 tools)

### 4.1 Bandit (Python)
- **Type**: SAST
- **Language**: Python
- **What it detects**:
  - SQL injection vectors
  - Command injection
  - Hardcoded passwords
  - Weak cryptography
  - Unsafe YAML loading
  - XXE vulnerabilities
  - Shell injection
  - Path traversal
- **Integration**: Pre-commit, CI/CD security scan
- **Output**: `bandit-report.json`, `bandit-report.html`, `bandit.sarif`
- **SARIF**: Yes (uploaded to GitHub Security)
- **GitHub**: https://github.com/PyCQA/bandit
- **Command**: `bandit -r main.py -f json`

### 4.2 Semgrep (Multi-language)
- **Type**: SAST
- **Language**: Python, JavaScript, and 30+ languages
- **What it detects**:
  - OWASP Top 10 issues
  - Security anti-patterns
  - CWE violations
  - Custom security rules
  - Business logic flaws
- **Integration**: CI/CD security scan stage
- **Output**: `semgrep-report.json`
- **SARIF**: Can generate SARIF
- **Website**: https://semgrep.dev
- **Command**: `semgrep --config=auto main.py`

### 4.3 ESLint Security Plugin (JavaScript)
- **Type**: SAST
- **Language**: JavaScript
- **What it detects**:
  - eval() usage
  - Unsafe RegEx
  - Insecure randomness
  - XSS vectors
  - Prototype pollution
- **Integration**: CI/CD security scan stage
- **Output**: `eslint-security-report.json`
- **Plugin**: eslint-plugin-security
- **Command**: `eslint --plugin security src/`

### 4.4 SonarQube (Optional)
- **Type**: SAST + Code Quality
- **Language**: Multi-language
- **What it checks**:
  - Security hotspots
  - Vulnerabilities
  - Code smells
  - Technical debt
  - Test coverage
  - Duplications
- **Integration**: Optional (secret configured)
- **Secret**: `SONAR_TOKEN`
- **Status**: ⚠️ **Configured but not active** (requires SonarQube/SonarCloud account)
- **Website**: https://www.sonarqube.org
- **How to enable**: 
  1. Sign up at https://sonarcloud.io
  2. Create project
  3. Add `SONAR_TOKEN` to GitHub Secrets
  4. Uncomment SonarQube step in workflows

---

## 🏗️ Category 5: IaC (Infrastructure as Code) Security (2 tools)

### 5.1 Checkov
- **Type**: IaC security scanner
- **Languages**: Dockerfile, docker-compose, Kubernetes, Terraform, CloudFormation
- **What it checks**:
  - Dockerfile best practices
  - Root user usage
  - Exposed ports
  - HEALTHCHECK presence
  - USER instruction
  - Security misconfigurations
  - CIS benchmarks
- **Integration**: CI/CD security scan stage
- **Output**: `checkov-dockerfile.json`, `checkov-nginx.json`
- **GitHub**: https://github.com/bridgecrewio/checkov
- **Command**: `checkov -f Dockerfile --framework dockerfile`

### 5.2 hadolint (Already listed in Code Quality)
- **Type**: Dockerfile linter
- Detects security and best practice violations in Dockerfiles

---

## 🐳 Category 6: Container Security (1 tool)

### 6.1 Trivy
- **Type**: Comprehensive vulnerability scanner
- **Language**: Multi-language
- **What it scans**:
  - **OS vulnerabilities**: Alpine, Debian, Ubuntu, RHEL, etc.
  - **Application dependencies**: Python, Node.js, Ruby, Go, etc.
  - **Container images**: Docker, OCI
  - **Filesystem**: Source code
  - **Git repositories**: Including history
  - **Kubernetes**: Manifests and clusters
  - **Misconfigurations**: Dockerfile, K8s, Terraform
- **Databases used**:
  - NVD (National Vulnerability Database)
  - CVE
  - GHSA (GitHub Security Advisories)
  - Distribution-specific advisories
- **Integration**: CI/CD container scan stage
- **Output**: 
  - `trivy-fs-report.sarif` (filesystem)
  - `trivy-image-report.json` (container)
  - `trivy-image-report.sarif` (container)
- **SARIF**: Yes (uploaded to GitHub Security)
- **GitHub**: https://github.com/aquasecurity/trivy
- **Commands**:
  - Filesystem: `trivy fs --severity CRITICAL,HIGH .`
  - Image: `trivy image --severity CRITICAL,HIGH service:tag`
  - SBOM: `trivy image --format cyclonedx service:tag`

---

## 📊 Category 7: Performance & Accessibility (1 tool)

### 7.1 Lighthouse CI
- **Type**: Performance, accessibility, SEO auditor
- **Language**: JavaScript (for web apps)
- **What it checks**:
  - Performance metrics (FCP, LCP, TTI)
  - Accessibility (WCAG compliance)
  - Best practices
  - SEO
  - PWA compliance
- **Integration**: CI/CD frontend pipeline
- **Output**: HTML reports, JSON
- **Website**: https://developers.google.com/web/tools/lighthouse
- **Command**: `lhci autorun`

---

## 🔄 Category 8: Continuous Monitoring (1 tool)

### 8.1 Dependabot
Already listed in Dependencies category, but worth highlighting:
- Automated weekly scans
- Security updates prioritized
- PRs created automatically
- Configured in `.github/dependabot.yml`

---

## 📋 Tools by Integration Point

### Pre-commit Hooks (9 tools)
1. detect-secrets
2. GitLeaks
3. Black
4. Flake8
5. isort
6. Bandit
7. mypy
8. hadolint
9. ESLint
10. Prettier

### CI/CD Pipeline (All 34 tools)
Organized by stage:
- **Validate**: TruffleHog, GitLeaks
- **Dependencies**: Safety, pip-audit, npm audit, Snyk, RetireJS, OWASP Dep-Check, CycloneDX, license-checker
- **Code Quality**: Black, Flake8, Pylint, mypy, isort, Radon, ESLint, Prettier, complexity-report, jscpd, TypeScript
- **Security**: Bandit, Semgrep, ESLint Security, SonarQube (optional)
- **IaC**: Checkov, hadolint
- **Container**: Trivy
- **Performance**: Lighthouse CI

### Local Development (Makefile)
All tools available via:
- `make security-scan-python`
- `make security-scan-frontend`
- `make security-secrets-scan`
- `make security-container-scan`
- `make security-iac-scan`
- `make security-sbom`
- `make security-full`

---

## 🆚 Tool Comparison by Category

### Secret Detection
| Tool | Patterns | Speed | False Positives |
|------|----------|-------|-----------------|
| TruffleHog | 700+ | Fast | Low |
| GitLeaks | 140+ | Very Fast | Very Low |
| detect-secrets | High-entropy | Fast | Medium |

**Recommendation**: Use all three for comprehensive coverage

### Python Dependency Security
| Tool | Database | Coverage | Speed |
|------|----------|----------|-------|
| Safety | PyUp.io | Good | Fast |
| pip-audit | OSV, PyPI | Excellent | Medium |

**Recommendation**: Use both - Safety for quick checks, pip-audit for comprehensive

### JavaScript Dependency Security
| Tool | Database | Coverage | Cost |
|------|----------|----------|------|
| npm audit | npm registry | Good | Free |
| Snyk | Proprietary | Excellent | Freemium |
| RetireJS | Retire.js DB | Good | Free |

**Recommendation**: npm audit + RetireJS free, add Snyk for enterprise

### SAST
| Tool | Languages | Rules | Learning Curve |
|------|-----------|-------|----------------|
| Bandit | Python | 100+ | Easy |
| Semgrep | 30+ | 1000+ | Medium |
| SonarQube | 29+ | 5000+ | Hard |

**Recommendation**: Bandit + Semgrep for most cases, SonarQube for enterprise

### Container Security
| Tool | Coverage | Databases | Speed |
|------|----------|-----------|-------|
| Trivy | Comprehensive | 10+ | Fast |

**Recommendation**: Trivy is excellent and covers most needs

---

## 💰 Cost Analysis

### Free Tools (27 tools)
All tools except Snyk and SonarQube are free and open-source:
- Total cost: **$0/month**
- GitHub Actions minutes: Free tier sufficient (2000 min/month)

### Freemium Tools (2 tools)

#### Snyk
- **Free tier**: 
  - 200 tests/month
  - Public repositories
  - Basic features
- **Paid tier**: $0-$500+/month
  - Unlimited tests
  - Private repositories
  - Advanced features
- **Status**: Optional, free tier sufficient for learning

#### SonarQube
- **SonarCloud Free**: 
  - Public repositories only
  - 100,000 lines of code
- **SonarCloud Paid**: $10-$6500+/month
- **Self-hosted**: Free (Community Edition)
- **Status**: Optional, not required

### Total Cost for Full Implementation
- **Learning/Personal**: $0/month
- **Small Team**: $0-100/month (optional Snyk Pro)
- **Enterprise**: $100-1000/month (Snyk + SonarQube)

---

## 🎯 Recommended Tool Combinations

### Minimum (Free)
For learning and personal projects:
```
Secrets: GitLeaks
Dependencies: Safety + npm audit
SAST: Bandit + Semgrep
Container: Trivy
```
**Cost**: $0/month

### Standard (Free)
For small teams and open-source:
```
Secrets: TruffleHog + GitLeaks
Dependencies: Safety + pip-audit + npm audit + RetireJS
Code Quality: Black + Flake8 + ESLint + Prettier
SAST: Bandit + Semgrep
IaC: Checkov
Container: Trivy
SBOM: CycloneDX
```
**Cost**: $0/month

### Enterprise (Paid)
For production and compliance:
```
All Standard tools +
Dependencies: Snyk
SAST: SonarQube
```
**Cost**: $100-1000/month

---

## 📊 Detection Coverage Matrix

| Vulnerability Type | Tools that Detect It |
|-------------------|---------------------|
| Hardcoded secrets | TruffleHog, GitLeaks, detect-secrets |
| Dependency CVEs | Safety, pip-audit, npm audit, Snyk, OWASP Dep-Check |
| SQL Injection | Bandit, Semgrep, SonarQube |
| XSS | Semgrep, ESLint Security, SonarQube |
| Command Injection | Bandit, Semgrep |
| Path Traversal | Bandit, Semgrep |
| Weak Crypto | Bandit, Semgrep |
| License Issues | license-checker |
| Container Vulns | Trivy |
| IaC Misconfig | Checkov, Trivy |
| Code Complexity | Radon, complexity-report, SonarQube |
| Code Duplication | jscpd, SonarQube |

---

## 🔧 How to Enable Optional Tools

### Enable Snyk
```bash
# 1. Sign up at https://snyk.io
# 2. Get your token
# 3. Add to GitHub Secrets:
#    SNYK_TOKEN = your_token_here
# 4. Already integrated in workflows!
```

### Enable SonarQube
```bash
# 1. Sign up at https://sonarcloud.io
# 2. Create a project
# 3. Get your token
# 4. Add to GitHub Secrets:
#    SONAR_TOKEN = your_token_here
# 5. Uncomment SonarQube step in workflows
# 6. Add sonar-project.properties
```

---

## 📚 Additional Resources

### Documentation
- [SECURITY_GUIDE.md](SECURITY_GUIDE.md) - How to use all tools
- [SECURITY_IMPLEMENTATION.md](SECURITY_IMPLEMENTATION.md) - What was implemented
- [.pre-commit-config.yaml](.pre-commit-config.yaml) - Pre-commit configuration

### External Links
- OWASP: https://owasp.org/www-project-dependency-check/
- Trivy: https://trivy.dev
- Semgrep: https://semgrep.dev
- Snyk: https://snyk.io
- SonarQube: https://www.sonarqube.org

---

## ✅ Summary

**Total Tools**: 34 (+ 2 optional)
**Free Tools**: 32
**Freemium Tools**: 2 (Snyk, SonarQube)
**Cost**: $0-1000/month depending on needs
**Coverage**: Comprehensive - from secrets to containers
**Integration**: CI/CD + Pre-commit + Local Makefile

**Status**: ✅ All tools configured and ready to use!

To see all tools in action: `make security-full`
