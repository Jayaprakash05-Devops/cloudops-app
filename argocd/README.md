# 🚀 ArgoCD GitOps Deployment for CloudOps

Complete ArgoCD setup for deploying CloudOps Command Center using GitOps methodology.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Options](#deployment-options)
- [Configuration](#configuration)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## 🎯 Overview

This directory contains ArgoCD Application manifests for deploying CloudOps services using the **App of Apps** pattern.

### What's Included

**📦 Service Applications (9):**
- cost-optimizer
- k8s-manager
- incident-manager
- automation-service
- chatops-bot
- metrics-collector
- auth-service
- frontend
- redis (shared)

**🎛️ Management:**
- `appproject.yaml` - CloudOps AppProject definition
- `app-of-apps/cloudops-parent.yaml` - Parent application (App of Apps)
- `applications/*.yaml` - Individual service applications

---

## 🏗️ Architecture

### App of Apps Pattern

```
cloudops-parent (ArgoCD Application)
│
├── cost-optimizer (Application)
│   └── helm/cost-optimizer (Helm Chart)
│
├── k8s-manager (Application)
│   └── helm/k8s-manager (Helm Chart)
│
├── incident-manager (Application)
│   └── helm/incident-manager (Helm Chart)
│
├── automation-service (Application)
│   └── helm/automation-service (Helm Chart)
│
├── chatops-bot (Application)
│   └── helm/chatops-bot (Helm Chart)
│
├── metrics-collector (Application)
│   └── helm/metrics-collector (Helm Chart)
│
├── auth-service (Application)
│   └── helm/auth-service (Helm Chart)
│
├── frontend (Application)
│   └── helm/frontend (Helm Chart)
│
└── cloudops-redis (Application)
    └── helm/redis (Helm Chart)
```

### GitOps Workflow

```
Developer → Git Push → ArgoCD Sync → Kubernetes Deploy
```

1. **Developer** commits changes to Git
2. **ArgoCD** detects changes in repository
3. **ArgoCD** automatically syncs to Kubernetes
4. **Kubernetes** deploys updated services

---

## ✅ Prerequisites

### 1. Kubernetes Cluster

```bash
# Minikube (local)
minikube start --cpus=4 --memory=8192

# Kind (local)
kind create cluster --name cloudops

# Or use existing cluster (EKS, GKE, AKS)
kubectl cluster-info
```

### 2. Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s \
  deployment/argocd-server -n argocd

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

### 3. Access ArgoCD UI

```bash
# Port forward ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open in browser
open https://localhost:8080

# Login with:
# Username: admin
# Password: (from step 2)
```

### 4. Install ArgoCD CLI (Optional)

```bash
# macOS
brew install argocd

# Linux
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# Login via CLI
argocd login localhost:8080
```

---

## 🚀 Quick Start

### Option 1: Deploy Everything (App of Apps)

Deploy all services at once using the parent application:

```bash
# 1. Update Git repository URL in manifests
sed -i 's|https://github.com/yourusername/cloudops.git|YOUR_GIT_REPO_URL|g' argocd/**/*.yaml

# 2. Create AppProject
kubectl apply -f argocd/appproject.yaml

# 3. Deploy parent application (App of Apps)
kubectl apply -f argocd/app-of-apps/cloudops-parent.yaml

# 4. Watch applications sync
kubectl get applications -n argocd -w

# 5. Check application status
argocd app list
```

### Option 2: Deploy Individual Services

Deploy services one by one:

```bash
# 1. Update Git repository URL
sed -i 's|https://github.com/yourusername/cloudops.git|YOUR_GIT_REPO_URL|g' argocd/applications/*.yaml

# 2. Create AppProject
kubectl apply -f argocd/appproject.yaml

# 3. Deploy Redis first (shared dependency)
kubectl apply -f argocd/applications/redis.yaml

# 4. Wait for Redis to be healthy
argocd app wait cloudops-redis --health

# 5. Deploy backend services
kubectl apply -f argocd/applications/cost-optimizer.yaml
kubectl apply -f argocd/applications/k8s-manager.yaml
kubectl apply -f argocd/applications/incident-manager.yaml
kubectl apply -f argocd/applications/automation-service.yaml
kubectl apply -f argocd/applications/chatops-bot.yaml
kubectl apply -f argocd/applications/metrics-collector.yaml

# 6. Deploy auth service
kubectl apply -f argocd/applications/auth-service.yaml

# 7. Deploy frontend
kubectl apply -f argocd/applications/frontend.yaml

# 8. Watch sync status
argocd app list
```

---

## ⚙️ Configuration

### Update Git Repository

**Before deploying, update the repository URL:**

```bash
# Replace with your actual Git repository
export GIT_REPO="https://github.com/YOUR_USERNAME/cloudops.git"

# Update all manifests
find argocd -name "*.yaml" -type f -exec sed -i \
  "s|https://github.com/yourusername/cloudops.git|${GIT_REPO}|g" {} \;
```

### Update Domain Name

For frontend ingress:

```bash
# Update frontend application
vim argocd/applications/frontend.yaml

# Change:
# host: cloudops.yourdomain.com
# To:
# host: cloudops.your-actual-domain.com
```

### Update JWT Secret Key

For production, use a secure JWT secret:

```bash
# Generate secure key
JWT_SECRET=$(openssl rand -base64 32)

# Update auth-service application
vim argocd/applications/auth-service.yaml

# Replace: jwtSecretKey: "CHANGE-ME-IN-PRODUCTION"
# With: jwtSecretKey: "$JWT_SECRET"
```

### Sync Policy Options

Each application has automated sync enabled by default:

```yaml
syncPolicy:
  automated:
    prune: true      # Delete resources when removed from Git
    selfHeal: true   # Auto-sync when cluster state differs
    allowEmpty: false
```

**To disable auto-sync** (manual sync required):

```yaml
syncPolicy:
  automated: {}  # Remove automated section
```

### Resource Customization

Override Helm values in application manifests:

```yaml
source:
  helm:
    values: |
      replicaCount: 5
      resources:
        limits:
          cpu: 2000m
          memory: 2Gi
```

---

## 📊 Monitoring

### ArgoCD UI

Access the ArgoCD web interface:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
open https://localhost:8080
```

**Features:**
- Application status dashboard
- Sync status and health
- Resource tree view
- Logs and events
- Manual sync controls

### CLI Commands

```bash
# List all applications
argocd app list

# Get application details
argocd app get cost-optimizer

# Watch application status
argocd app wait cost-optimizer --health

# View sync status
argocd app sync-status cost-optimizer

# View application logs
argocd app logs cost-optimizer

# View resources
argocd app resources cost-optimizer
```

### Kubernetes Native

```bash
# Get applications
kubectl get applications -n argocd

# Describe application
kubectl describe application cost-optimizer -n argocd

# Get application status
kubectl get application cost-optimizer -n argocd -o jsonpath='{.status.sync.status}'

# Get health status
kubectl get application cost-optimizer -n argocd -o jsonpath='{.status.health.status}'
```

### Application Health Status

| Status | Description |
|--------|-------------|
| **Healthy** | All resources are healthy |
| **Progressing** | Deployment in progress |
| **Degraded** | Some resources are unhealthy |
| **Suspended** | Application is suspended |
| **Missing** | Resources are missing |
| **Unknown** | Health status unknown |

### Sync Status

| Status | Description |
|--------|-------------|
| **Synced** | Git and cluster are in sync |
| **OutOfSync** | Cluster differs from Git |
| **Unknown** | Sync status unknown |

---

## 🔧 Troubleshooting

### Application Not Syncing

**Check sync status:**

```bash
argocd app get cost-optimizer
```

**Force sync:**

```bash
argocd app sync cost-optimizer
```

**Check for sync errors:**

```bash
kubectl describe application cost-optimizer -n argocd
```

### Application Unhealthy

**Check pod status:**

```bash
kubectl get pods -n cloudops -l app.kubernetes.io/name=cost-optimizer
```

**Check pod logs:**

```bash
kubectl logs -n cloudops -l app.kubernetes.io/name=cost-optimizer
```

**Check events:**

```bash
kubectl get events -n cloudops --sort-by='.lastTimestamp'
```

### Repository Connection Issues

**Test repository access:**

```bash
argocd repo list
argocd repo get https://github.com/yourusername/cloudops.git
```

**Add repository credentials:**

```bash
argocd repo add https://github.com/yourusername/cloudops.git \
  --username YOUR_USERNAME \
  --password YOUR_TOKEN
```

### Helm Values Not Applied

**Check rendered manifests:**

```bash
argocd app manifests cost-optimizer
```

**Update application:**

```bash
kubectl apply -f argocd/applications/cost-optimizer.yaml
argocd app sync cost-optimizer --force
```

### Sync Operation Stuck

**Terminate sync operation:**

```bash
argocd app terminate-op cost-optimizer
```

**Delete and recreate application:**

```bash
kubectl delete application cost-optimizer -n argocd
kubectl apply -f argocd/applications/cost-optimizer.yaml
```

### Common Error Messages

**Error: "resource XXX is not permitted in project"**

- Check AppProject permissions in `appproject.yaml`
- Ensure resource is whitelisted

**Error: "Unable to create application: permission denied"**

- Check RBAC roles
- Verify user has correct permissions

**Error: "ComparisonError: rpc error: code = Unknown"**

- Check Helm chart syntax
- Validate values.yaml
- Run `helm template` locally to test

---

## 🎯 Best Practices

### 1. Use App of Apps Pattern

Deploy the parent application to manage all services:

```bash
kubectl apply -f argocd/app-of-apps/cloudops-parent.yaml
```

**Benefits:**
- Single deployment point
- Consistent configuration
- Easy rollback
- Dependency management

### 2. Environment-Specific Configurations

Create separate applications for different environments:

```yaml
# argocd/applications/cost-optimizer-prod.yaml
metadata:
  name: cost-optimizer-prod
spec:
  source:
    targetRevision: main
    helm:
      valueFiles:
        - values.yaml
        - values-production.yaml
  destination:
    namespace: cloudops-prod
```

### 3. Use Git Branches for Environments

```yaml
# Development
targetRevision: develop

# Staging
targetRevision: staging

# Production
targetRevision: main
```

### 4. Enable Notifications

Configure ArgoCD notifications for Slack/Email:

```bash
kubectl apply -f argocd/notifications-configmap.yaml
```

### 5. Use Health Checks

Define custom health checks for applications:

```yaml
spec:
  source:
    helm:
      values: |
        livenessProbe:
          enabled: true
        readinessProbe:
          enabled: true
```

### 6. Resource Pruning

Enable automatic resource pruning:

```yaml
syncPolicy:
  automated:
    prune: true
```

### 7. Self-Healing

Enable auto-sync for drift correction:

```yaml
syncPolicy:
  automated:
    selfHeal: true
```

### 8. Ignore Differences

Ignore HPA-managed replicas:

```yaml
ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
      - /spec/replicas
```

### 9. Use Projects for Multi-Tenancy

Separate projects for different teams:

```bash
kubectl apply -f argocd/appproject-team1.yaml
kubectl apply -f argocd/appproject-team2.yaml
```

### 10. Monitor Application Status

Set up monitoring dashboards:

```bash
# Prometheus metrics
kubectl port-forward svc/argocd-metrics -n argocd 8082:8082

# Grafana dashboard
# Import ArgoCD dashboard ID: 14584
```

---

## 📚 Additional Resources

### ArgoCD Documentation
- Official Docs: https://argo-cd.readthedocs.io/
- Best Practices: https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/
- App of Apps: https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/

### CloudOps Documentation
- Helm Charts: `../helm/README.md`
- Kubernetes Guide: `../docs/KUBERNETES_HELM_DEPLOYMENT.md`
- Deployment Examples: `../helm/DEPLOYMENT_EXAMPLES.md`

### Commands Reference

```bash
# Application Management
argocd app list
argocd app get <app-name>
argocd app create <app-name>
argocd app delete <app-name>
argocd app sync <app-name>
argocd app wait <app-name>

# Repository Management
argocd repo list
argocd repo add <repo-url>
argocd repo rm <repo-url>

# Project Management
argocd proj list
argocd proj create <project-name>
argocd proj delete <project-name>

# Settings
argocd account list
argocd cluster list
argocd version
```

---

## 🎊 Summary

✅ **ArgoCD Applications Created:**
- 9 service applications
- 1 parent application (App of Apps)
- 1 AppProject for RBAC

✅ **GitOps Features:**
- Automated sync from Git
- Self-healing enabled
- Resource pruning
- Rollback support
- Multi-environment ready

✅ **Monitoring:**
- ArgoCD UI dashboard
- CLI monitoring
- Health checks
- Sync status tracking

**Deploy now:**

```bash
# Update Git repository URL
export GIT_REPO="https://github.com/YOUR_USERNAME/cloudops.git"
find argocd -name "*.yaml" -type f -exec sed -i "s|https://github.com/yourusername/cloudops.git|${GIT_REPO}|g" {} \;

# Deploy everything
kubectl apply -f argocd/appproject.yaml
kubectl apply -f argocd/app-of-apps/cloudops-parent.yaml

# Watch deployment
argocd app list -w
```

**Your CloudOps platform is now GitOps-ready! 🚀**

---

**Questions?** Check the [troubleshooting section](#troubleshooting) or refer to the [ArgoCD documentation](https://argo-cd.readthedocs.io/).
