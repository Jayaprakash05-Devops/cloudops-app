# 🚀 ArgoCD GitOps Deployment Guide

Complete guide for deploying CloudOps Command Center using ArgoCD and GitOps methodology.

---

## 📋 Table of Contents

- [Introduction](#introduction)
- [What is GitOps?](#what-is-gitops)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Deployment](#deployment)
- [Monitoring](#monitoring)
- [Operations](#operations)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Introduction

This guide shows you how to deploy CloudOps using **ArgoCD**, a declarative GitOps continuous delivery tool for Kubernetes.

### What You'll Learn

- Set up ArgoCD on Kubernetes
- Deploy CloudOps using GitOps
- Monitor applications via ArgoCD
- Manage multi-service deployments
- Implement GitOps best practices

### What's Included

**📦 ArgoCD Applications:**
- 9 service applications
- 1 parent application (App of Apps pattern)
- 1 AppProject for RBAC
- Monitoring dashboards
- Alerting rules

---

## 🔄 What is GitOps?

**GitOps** is a way of managing Kubernetes applications where:

1. **Git is the single source of truth**
   - All configuration stored in Git
   - All changes go through Git
   - Git history = deployment history

2. **Automated synchronization**
   - ArgoCD monitors Git repository
   - Detects changes automatically
   - Syncs to Kubernetes cluster

3. **Declarative configuration**
   - Describe desired state
   - ArgoCD ensures actual state matches
   - Self-healing capabilities

### Traditional vs GitOps

**Traditional Deployment:**
```
Developer → kubectl apply → Kubernetes
```

**GitOps with ArgoCD:**
```
Developer → Git Push → ArgoCD Detects → Auto Sync → Kubernetes
```

### Benefits

✅ **Version Control** - All changes tracked in Git  
✅ **Audit Trail** - Complete deployment history  
✅ **Rollback** - Easy revert to any previous state  
✅ **Automation** - No manual kubectl commands  
✅ **Consistency** - Same process for all environments  
✅ **Security** - RBAC on Git instead of cluster  
✅ **Disaster Recovery** - Cluster state in Git  

---

## 🏗️ Architecture

### App of Apps Pattern

```
┌─────────────────────────────────────────────────┐
│          cloudops-parent (Application)          │
│              App of Apps Pattern                │
└─────────────────┬───────────────────────────────┘
                  │
                  ├─────────────────────────────────┐
                  │                                 │
        ┌─────────▼─────────┐           ┌─────────▼─────────┐
        │  cost-optimizer   │           │   k8s-manager     │
        │   (Application)   │           │   (Application)   │
        └─────────┬─────────┘           └─────────┬─────────┘
                  │                               │
        ┌─────────▼─────────┐           ┌─────────▼─────────┐
        │    Helm Chart     │           │    Helm Chart     │
        │   (Kubernetes)    │           │   (Kubernetes)    │
        └───────────────────┘           └───────────────────┘
```

### Components

**1. AppProject (cloudops)**
- RBAC for CloudOps applications
- Repository access control
- Destination namespaces
- Role-based permissions

**2. Parent Application (cloudops-parent)**
- Monitors `argocd/applications/` directory
- Creates child applications automatically
- Manages application lifecycle

**3. Child Applications (9 services)**
- cost-optimizer
- k8s-manager
- incident-manager
- automation-service
- chatops-bot
- metrics-collector
- auth-service
- frontend
- redis

**4. Helm Charts**
- Source of truth for Kubernetes manifests
- Located in `helm/<service>/`
- Customizable via values

---

## ✅ Prerequisites

### 1. Kubernetes Cluster

You need a running Kubernetes cluster:

**Local Options:**
```bash
# Minikube
minikube start --cpus=4 --memory=8192

# Kind
kind create cluster --name cloudops

# Docker Desktop
# Enable Kubernetes in settings
```

**Cloud Options:**
- Amazon EKS
- Google GKE
- Azure AKS
- DigitalOcean Kubernetes

### 2. Command Line Tools

```bash
# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/$(uname -s | tr '[:upper:]' '[:lower:]')/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify
kubectl version --client

# ArgoCD CLI (optional but recommended)
# macOS
brew install argocd

# Linux
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# Verify
argocd version --client
```

### 3. Git Repository

Your code must be in a Git repository (GitHub, GitLab, Bitbucket, etc.).

```bash
# Verify Git repository
git remote -v

# Should show your repository URL
# origin  https://github.com/yourusername/cloudops.git
```

---

## 📦 Installation

### Step 1: Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=600s \
  deployment/argocd-server -n argocd

# Verify installation
kubectl get pods -n argocd
```

**Expected output:**
```
NAME                                  READY   STATUS    RESTARTS   AGE
argocd-application-controller-0       1/1     Running   0          2m
argocd-dex-server-xxx                 1/1     Running   0          2m
argocd-redis-xxx                      1/1     Running   0          2m
argocd-repo-server-xxx                1/1     Running   0          2m
argocd-server-xxx                     1/1     Running   0          2m
```

### Step 2: Access ArgoCD UI

```bash
# Get initial admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

echo "ArgoCD Admin Password: $ARGOCD_PASSWORD"

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Open browser
open https://localhost:8080
```

**Login Credentials:**
- Username: `admin`
- Password: (from command above)

### Step 3: Login via CLI (Optional)

```bash
# Login
argocd login localhost:8080

# Username: admin
# Password: (paste from above)

# Change admin password (recommended)
argocd account update-password
```

### Step 4: Configure Git Repository Access

**For Public Repositories:**
No additional configuration needed.

**For Private Repositories with HTTPS:**

```bash
# Create repository secret
kubectl create secret generic repo-credentials -n argocd \
  --from-literal=type=git \
  --from-literal=url=https://github.com/yourusername/cloudops.git \
  --from-literal=username=YOUR_GITHUB_USERNAME \
  --from-literal=password=YOUR_GITHUB_TOKEN

# Label the secret
kubectl label secret repo-credentials -n argocd \
  argocd.argoproj.io/secret-type=repository
```

**For Private Repositories with SSH:**

```bash
# Generate SSH key
ssh-keygen -t ed25519 -f ~/.ssh/argocd_key -N ""

# Add public key to GitHub
cat ~/.ssh/argocd_key.pub
# Copy and add to GitHub: Settings → SSH Keys

# Create secret
kubectl create secret generic argocd-ssh-key -n argocd \
  --from-file=sshPrivateKey=$HOME/.ssh/argocd_key

# Label the secret
kubectl label secret argocd-ssh-key -n argocd \
  argocd.argoproj.io/secret-type=repository
```

---

## 🚀 Deployment

### Option 1: Deploy Everything (Recommended)

Deploy all CloudOps services at once using the App of Apps pattern:

```bash
# 1. Update Git repository URL
cd argocd/
export GIT_REPO="https://github.com/YOUR_USERNAME/cloudops.git"

find . -name "*.yaml" -type f -exec sed -i \
  "s|https://github.com/yourusername/cloudops.git|${GIT_REPO}|g" {} \;

# 2. Create AppProject
kubectl apply -f appproject.yaml

# 3. Deploy parent application
kubectl apply -f app-of-apps/cloudops-parent.yaml

# 4. Watch applications sync
kubectl get applications -n argocd -w
```

**What happens:**
1. Parent application is created
2. ArgoCD scans `argocd/applications/` directory
3. Creates 9 child applications automatically
4. Each application syncs its Helm chart
5. All services deploy to Kubernetes

### Option 2: Deploy Services Individually

Deploy services one by one for more control:

```bash
# 1. Update Git repository URL
cd argocd/
export GIT_REPO="https://github.com/YOUR_USERNAME/cloudops.git"

find applications/ -name "*.yaml" -type f -exec sed -i \
  "s|https://github.com/yourusername/cloudops.git|${GIT_REPO}|g" {} \;

# 2. Create AppProject
kubectl apply -f appproject.yaml

# 3. Deploy Redis first (shared dependency)
kubectl apply -f applications/redis.yaml

# Wait for Redis to be healthy
kubectl get application cloudops-redis -n argocd -w

# 4. Deploy backend services
for service in cost-optimizer k8s-manager incident-manager \
               automation-service chatops-bot metrics-collector; do
  kubectl apply -f applications/$service.yaml
done

# 5. Deploy auth service
kubectl apply -f applications/auth-service.yaml

# 6. Deploy frontend
kubectl apply -f applications/frontend.yaml

# 7. Check all applications
kubectl get applications -n argocd
```

### Option 3: Use Kustomize

```bash
# Deploy with kustomize
cd argocd/
kubectl apply -k .

# This will create:
# - AppProject
# - Parent Application
# - All monitoring (if uncommented)
```

### Verify Deployment

```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Expected output:
NAME                  SYNC STATUS   HEALTH STATUS
cloudops-parent       Synced        Healthy
cost-optimizer        Synced        Healthy
k8s-manager           Synced        Healthy
incident-manager      Synced        Healthy
automation-service    Synced        Healthy
chatops-bot           Synced        Healthy
metrics-collector     Synced        Healthy
auth-service          Synced        Healthy
frontend              Synced        Healthy
cloudops-redis        Synced        Healthy

# Check pods in cloudops namespace
kubectl get pods -n cloudops

# Check services
kubectl get svc -n cloudops

# Access frontend
kubectl port-forward svc/frontend -n cloudops 3000:3000
open http://localhost:3000
```

---

## 📊 Monitoring

### ArgoCD UI Dashboard

```bash
# Access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
open https://localhost:8080
```

**UI Features:**
- Application health status
- Sync status
- Resource tree view
- Live manifest comparison
- Event logs
- Manual sync controls

### CLI Monitoring

```bash
# List all applications
argocd app list

# Get application details
argocd app get cost-optimizer

# Watch application
argocd app wait cost-optimizer --health

# View logs
argocd app logs cost-optimizer

# View sync status
argocd app sync-status cost-optimizer
```

### Application Status

**Sync Status:**
- **Synced** ✅ - Git and cluster match
- **OutOfSync** ⚠️ - Differences detected
- **Unknown** ❓ - Status unknown

**Health Status:**
- **Healthy** ✅ - All resources healthy
- **Progressing** 🔄 - Deployment in progress
- **Degraded** ⚠️ - Some issues detected
- **Suspended** ⏸️ - Application suspended
- **Missing** ❌ - Resources missing

### Prometheus Metrics

```bash
# Deploy monitoring (optional)
kubectl apply -f argocd/monitoring/prometheus-servicemonitor.yaml
kubectl apply -f argocd/monitoring/alerts.yaml

# Access Prometheus
kubectl port-forward svc/prometheus -n monitoring 9090:9090
```

**Key Metrics:**
- `argocd_app_info` - Application metadata
- `argocd_app_sync_total` - Sync operations
- `argocd_app_reconcile` - Reconciliation time
- `argocd_git_request_duration_seconds` - Git latency

### Grafana Dashboard

```bash
# Deploy Grafana dashboard
kubectl apply -f argocd/monitoring/grafana-dashboard-configmap.yaml

# Access Grafana
kubectl port-forward svc/grafana -n monitoring 3000:3000

# Import dashboard ID: 14584 (ArgoCD official)
```

---

## 🔧 Operations

### Manual Sync

```bash
# Sync via CLI
argocd app sync cost-optimizer

# Sync with prune
argocd app sync cost-optimizer --prune

# Sync all applications
argocd app sync --all
```

### Rollback

```bash
# View history
argocd app history cost-optimizer

# Rollback to specific revision
argocd app rollback cost-optimizer <revision-id>

# Example
argocd app rollback cost-optimizer 5
```

### Update Configuration

**1. Update Helm values in Git:**

```bash
# Edit application manifest
vim argocd/applications/cost-optimizer.yaml

# Update values section
source:
  helm:
    values: |
      replicaCount: 5
      resources:
        limits:
          memory: 2Gi

# Commit and push
git add argocd/applications/cost-optimizer.yaml
git commit -m "Scale cost-optimizer to 5 replicas"
git push
```

**2. ArgoCD auto-syncs (if enabled):**

If auto-sync is disabled, manually sync:
```bash
argocd app sync cost-optimizer
```

### Refresh Application

Force ArgoCD to check Git for changes:

```bash
argocd app get cost-optimizer --refresh
```

### Diff Before Sync

See what will change before syncing:

```bash
argocd app diff cost-optimizer
```

### Suspend Auto-Sync

Temporarily disable auto-sync:

```bash
# Suspend
argocd app set cost-optimizer --sync-policy none

# Re-enable
argocd app set cost-optimizer --sync-policy automated
```

---

## 🎯 Best Practices

### 1. Use App of Apps Pattern

**Benefits:**
- Single deployment entry point
- Consistent configuration
- Easy dependency management
- Simplified rollback

**Implementation:**
```bash
kubectl apply -f argocd/app-of-apps/cloudops-parent.yaml
```

### 2. Environment-Specific Configurations

Create separate applications for each environment:

```yaml
# production
spec:
  source:
    targetRevision: main
    helm:
      valueFiles:
        - values.yaml
        - values-production.yaml

# staging
spec:
  source:
    targetRevision: staging
    helm:
      valueFiles:
        - values.yaml
        - values-staging.yaml
```

### 3. Use Projects for RBAC

Define projects for different teams:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-backend
spec:
  roles:
    - name: developer
      policies:
        - p, proj:team-backend:developer, applications, sync, team-backend/*, allow
```

### 4. Enable Automated Sync

For most services:

```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

### 5. Ignore HPA-Managed Replicas

Prevent sync conflicts:

```yaml
ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
      - /spec/replicas
```

### 6. Use Sync Waves

Control deployment order:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"  # Deploy first
```

### 7. Set Up Notifications

Configure Slack notifications:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
data:
  service.slack: |
    token: $slack-token
```

### 8. Regular Backups

Backup ArgoCD configuration:

```bash
kubectl get applications -n argocd -o yaml > argocd-backup.yaml
kubectl get appprojects -n argocd -o yaml >> argocd-backup.yaml
```

### 9. Use Health Checks

Define custom health checks for your applications.

### 10. Monitor Performance

Track ArgoCD metrics:
- Sync duration
- Reconciliation time
- Git fetch time
- Resource usage

---

## 🔍 Troubleshooting

### Application Not Syncing

**Check logs:**
```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

**Force sync:**
```bash
argocd app sync cost-optimizer --force
```

### Application Unhealthy

**Check pods:**
```bash
kubectl get pods -n cloudops -l app.kubernetes.io/name=cost-optimizer
kubectl logs -n cloudops <pod-name>
```

### Repository Connection Failed

**Test connection:**
```bash
argocd repo list
```

**Re-add repository:**
```bash
argocd repo rm https://github.com/yourusername/cloudops.git
argocd repo add https://github.com/yourusername/cloudops.git \
  --username YOUR_USERNAME \
  --password YOUR_TOKEN
```

### Helm Template Errors

**Test locally:**
```bash
cd helm/cost-optimizer
helm template test . --debug
helm lint .
```

**For detailed troubleshooting:**
See [TROUBLESHOOTING.md](../argocd/TROUBLESHOOTING.md)

---

## 📚 Additional Resources

### Documentation
- [ArgoCD Quick Start](../argocd/QUICK_START.md)
- [ArgoCD README](../argocd/README.md)
- [Troubleshooting Guide](../argocd/TROUBLESHOOTING.md)
- [Kubernetes Deployment](KUBERNETES_HELM_DEPLOYMENT.md)

### External Links
- [ArgoCD Official Docs](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://www.gitops.tech/)
- [App of Apps Pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)

---

## ✅ Summary

You now have:

✅ **ArgoCD installed** on Kubernetes  
✅ **GitOps workflow** configured  
✅ **9 CloudOps services** deployed  
✅ **App of Apps** pattern implemented  
✅ **Monitoring** and alerting set up  
✅ **Automated sync** from Git  
✅ **Self-healing** capabilities  

**Your CloudOps platform is now fully GitOps-enabled! 🎉**

All configuration changes now go through Git, providing:
- Version control
- Audit trail
- Easy rollback
- Consistent deployments
- Automated sync

**Next Steps:**
1. Customize configurations for your environment
2. Set up notifications (Slack/Email)
3. Configure multi-environment deployment
4. Implement CI/CD pipeline integration
5. Monitor application health and performance

---

**Questions?** Check the [troubleshooting guide](../argocd/TROUBLESHOOTING.md) or [ArgoCD documentation](https://argo-cd.readthedocs.io/).
