# 🚀 Helm Deployment Guide - CloudOps Command Center

## 📊 What Was Created

### Complete Helm Chart Structure

```
helm/cloudops/
├── Chart.yaml                      # Chart metadata
├── values.yaml                     # Default values
├── values-production.yaml          # Production configuration
├── values-development.yaml         # Development configuration
├── README.md                       # Chart documentation
├── templates/
│   ├── _helpers.tpl               # Template helpers
│   ├── NOTES.txt                  # Post-install instructions
│   ├── cost-optimizer/
│   │   ├── deployment.yaml        # Deployment with security contexts
│   │   ├── service.yaml           # ClusterIP service
│   │   ├── hpa.yaml              # Horizontal Pod Autoscaler
│   │   ├── pdb.yaml              # Pod Disruption Budget
│   │   └── configmap.yaml        # Configuration
│   ├── k8s-manager/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── hpa.yaml
│   │   ├── pdb.yaml
│   │   ├── configmap.yaml
│   │   ├── serviceaccount.yaml   # K8s API access
│   │   └── rbac.yaml             # Cluster roles
│   ├── incident-manager/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── hpa.yaml
│   │   ├── pdb.yaml
│   │   └── configmap.yaml
│   ├── automation-service/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── hpa.yaml
│   │   ├── pdb.yaml
│   │   └── configmap.yaml
│   ├── chatops-bot/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── hpa.yaml
│   │   ├── pdb.yaml
│   │   └── configmap.yaml
│   ├── metrics-collector/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── hpa.yaml
│   │   ├── pdb.yaml
│   │   └── configmap.yaml
│   └── frontend/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── hpa.yaml
│       ├── pdb.yaml
│       ├── configmap.yaml
│       └── ingress.yaml          # Public ingress
```

---

## ✨ Key Features

### 1. High Availability (HA)
- **Pod Disruption Budgets (PDB)** for all services
- Multiple replicas (2-5 depending on service)
- Anti-affinity rules to spread pods across nodes

### 2. Auto-Scaling
- **Horizontal Pod Autoscaler (HPA)** for all services
- CPU-based scaling (target: 70%)
- Memory-based scaling (target: 80%)
- Smart scale-up/scale-down policies
- Min: 2-3 replicas, Max: 8-30 replicas

### 3. Security
- Non-root containers (UID 1000)
- Read-only root filesystem
- Security contexts
- RBAC for K8s Manager
- Service accounts
- Network policies (optional)

### 4. Production-Ready
- Resource limits and requests
- Liveness and readiness probes
- ConfigMaps for configuration
- Secrets management support
- Ingress with TLS support
- Redis dependency management

---

## 🚀 Quick Start

### Prerequisites

```bash
# Required
- Kubernetes 1.23+
- Helm 3.8+
- kubectl configured

# Optional (but recommended)
- Metrics Server (for HPA)
- cert-manager (for TLS)
- Ingress Controller (nginx)
```

### Step 1: Install Metrics Server (for HPA)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Step 2: Add Helm Repositories

```bash
# Add Bitnami repo for Redis dependency
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Step 3: Create Namespace

```bash
kubectl create namespace cloudops
```

### Step 4: Create Secrets (Optional)

```bash
# AWS Credentials
kubectl create secret generic aws-credentials \
  --namespace cloudops \
  --from-literal=AWS_ACCESS_KEY_ID=your_key \
  --from-literal=AWS_SECRET_ACCESS_KEY=your_secret

# GitHub Token
kubectl create secret generic github-credentials \
  --namespace cloudops \
  --from-literal=GITHUB_TOKEN=ghp_your_token \
  --from-literal=GITHUB_REPO=username/repo

# PagerDuty API Key
kubectl create secret generic pagerduty-credentials \
  --namespace cloudops \
  --from-literal=PAGERDUTY_API_KEY=your_api_key

# Slack Bot Token
kubectl create secret generic slack-credentials \
  --namespace cloudops \
  --from-literal=SLACK_BOT_TOKEN=xoxb-your-token
```

### Step 5: Install Chart

```bash
# Development (minimal resources)
helm install cloudops ./helm/cloudops \
  --namespace cloudops \
  --values helm/cloudops/values-development.yaml

# Production (HA, auto-scaling, PDB)
helm install cloudops ./helm/cloudops \
  --namespace cloudops \
  --values helm/cloudops/values-production.yaml
```

---

## 🎯 Deployment Scenarios

### Scenario 1: Local Development (Minikube/Kind)

```bash
# Install with development values
helm install cloudops ./helm/cloudops \
  --namespace cloudops \
  --create-namespace \
  --values helm/cloudops/values-development.yaml

# Port-forward frontend
kubectl port-forward -n cloudops svc/cloudops-frontend 3000:3000

# Access at http://localhost:3000
```

### Scenario 2: Production on EKS/GKE/AKS

```bash
# Create production secrets
kubectl create secret generic aws-credentials --namespace cloudops \
  --from-literal=AWS_ACCESS_KEY_ID=$AWS_KEY \
  --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET

# Install with production values
helm install cloudops ./helm/cloudops \
  --namespace cloudops \
  --create-namespace \
  --values helm/cloudops/values-production.yaml \
  --set frontend.ingress.hosts[0].host=cloudops.yourdomain.com

# Wait for ingress
kubectl wait --for=condition=available --timeout=300s \
  deployment -l app.kubernetes.io/instance=cloudops -n cloudops

# Check ingress
kubectl get ingress -n cloudops
```

### Scenario 3: Testing HPA and PDB

```bash
# Install with default values (HPA + PDB enabled)
helm install cloudops ./helm/cloudops --namespace cloudops

# Generate load to test auto-scaling
kubectl run -it --rm load-generator --image=busybox --namespace cloudops -- \
  /bin/sh -c "while true; do wget -q -O- http://cloudops-cost-optimizer:8001/costs/summary; done"

# Watch HPA scale up
kubectl get hpa -n cloudops -w

# Test PDB (try to drain a node)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# PDB will prevent too many pods from being evicted at once
kubectl get pdb -n cloudops
```

---

## 📊 HPA Configuration Details

### Default HPA Settings

Each service has HPA configured with:

```yaml
minReplicas: 2
maxReplicas: 10
targetCPUUtilizationPercentage: 70
targetMemoryUtilizationPercentage: 80

# Scale-up behavior
scaleUp:
  stabilizationWindowSeconds: 0
  policies:
  - type: Percent
    value: 100  # Double pods in 30 seconds
    periodSeconds: 30
  - type: Pods
    value: 4    # Add 4 pods in 30 seconds
    periodSeconds: 30

# Scale-down behavior
scaleDown:
  stabilizationWindowSeconds: 300  # Wait 5 minutes before scaling down
  policies:
  - type: Percent
    value: 50   # Remove 50% of pods in 60 seconds
    periodSeconds: 60
  - type: Pods
    value: 2    # Remove 2 pods in 60 seconds
    periodSeconds: 60
```

### Viewing HPA Status

```bash
# Get HPA status
kubectl get hpa -n cloudops

# Detailed HPA info
kubectl describe hpa cloudops-cost-optimizer -n cloudops

# Watch HPA in real-time
kubectl get hpa -n cloudops -w

# Check current pod metrics
kubectl top pods -n cloudops
```

---

## 🛡️ PDB Configuration Details

### Default PDB Settings

Each service has PDB to ensure high availability:

```yaml
# Backend services
minAvailable: 1  # Always keep at least 1 pod running

# Frontend
minAvailable: 2  # Always keep at least 2 pods running
```

### Viewing PDB Status

```bash
# Get PDB status
kubectl get pdb -n cloudops

# Detailed PDB info
kubectl describe pdb cloudops-cost-optimizer -n cloudops

# Check what's allowed during disruptions
kubectl get pdb -n cloudops -o custom-columns=NAME:.metadata.name,MIN-AVAILABLE:.spec.minAvailable,ALLOWED-DISRUPTIONS:.status.disruptionsAllowed
```

---

## 🔧 Common Operations

### Upgrade

```bash
# Upgrade with new values
helm upgrade cloudops ./helm/cloudops \
  --namespace cloudops \
  --values helm/cloudops/values-production.yaml

# Force recreation
helm upgrade cloudops ./helm/cloudops \
  --namespace cloudops \
  --force
```

### Rollback

```bash
# View history
helm history cloudops --namespace cloudops

# Rollback to previous version
helm rollback cloudops --namespace cloudops

# Rollback to specific revision
helm rollback cloudops 2 --namespace cloudops
```

### Uninstall

```bash
helm uninstall cloudops --namespace cloudops
```

### Scale Manually

```bash
# Disable HPA first
kubectl patch hpa cloudops-cost-optimizer -n cloudops \
  --patch '{"spec": {"minReplicas": 5, "maxReplicas": 5}}'

# Or scale deployment directly (HPA will override this)
kubectl scale deployment cloudops-cost-optimizer -n cloudops --replicas=5
```

---

## 🧪 Testing

### Test 1: Verify All Pods Running

```bash
kubectl get pods -n cloudops

# Should see:
# - cost-optimizer: 2+ pods
# - k8s-manager: 2+ pods
# - incident-manager: 2+ pods
# - automation-service: 2+ pods
# - chatops-bot: 2+ pods
# - metrics-collector: 2+ pods
# - frontend: 3+ pods
# - redis-master: 1 pod
```

### Test 2: Verify HPA Working

```bash
# Check HPA targets
kubectl get hpa -n cloudops

# Should see current CPU/Memory usage
# NAME                          REFERENCE                        TARGETS   MINPODS   MAXPODS   REPLICAS
# cloudops-cost-optimizer       Deployment/cloudops-cost-...     45%/70%   2         10        2
```

### Test 3: Verify PDB Active

```bash
# Check PDB allowed disruptions
kubectl get pdb -n cloudops

# Should see:
# NAME                          MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS
# cloudops-cost-optimizer       1               N/A               1
# cloudops-frontend             2               N/A               1
```

### Test 4: Verify Services Accessible

```bash
# Port-forward and test
kubectl port-forward -n cloudops svc/cloudops-cost-optimizer 8001:8001 &
curl http://localhost:8001/health

# Should return: {"status": "healthy"}
```

### Test 5: Load Test Auto-Scaling

```bash
# Install hey load tester
kubectl run -it --rm load-test --image=williamyeh/hey --namespace cloudops -- \
  -z 5m -c 50 http://cloudops-cost-optimizer:8001/costs/summary

# Watch pods scale
kubectl get hpa -n cloudops -w
kubectl get pods -n cloudops -w
```

---

## 🐛 Troubleshooting

### Issue: Pods Not Scaling

**Problem:** HPA shows "unknown" for CPU/Memory

**Solution:**
```bash
# Check metrics-server is running
kubectl get deployment metrics-server -n kube-system

# Install if missing
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Check metrics available
kubectl top nodes
kubectl top pods -n cloudops
```

### Issue: PDB Blocking Node Drain

**Problem:** Can't drain node due to PDB

**Solution:**
```bash
# Check PDB status
kubectl get pdb -n cloudops

# Temporarily increase replicas
kubectl scale deployment cloudops-cost-optimizer -n cloudops --replicas=5

# Or delete PDB temporarily (not recommended in production!)
kubectl delete pdb cloudops-cost-optimizer -n cloudops
```

### Issue: Pods Crash Looping

**Solution:**
```bash
# Check logs
kubectl logs -n cloudops -l app.kubernetes.io/component=cost-optimizer --tail=100

# Check events
kubectl get events -n cloudops --sort-by='.lastTimestamp'

# Check resource limits
kubectl describe pod <pod-name> -n cloudops
```

### Issue: Frontend Ingress Not Working

**Solution:**
```bash
# Check ingress
kubectl get ingress -n cloudops
kubectl describe ingress cloudops-frontend -n cloudops

# Check ingress controller
kubectl get pods -n ingress-nginx

# Test service directly
kubectl port-forward -n cloudops svc/cloudops-frontend 3000:3000
```

---

## 📈 Monitoring

### View Resource Usage

```bash
# Per pod
kubectl top pods -n cloudops

# Per node
kubectl top nodes
```

### View Scaling Events

```bash
# HPA events
kubectl describe hpa -n cloudops

# Deployment events
kubectl describe deployment cloudops-cost-optimizer -n cloudops
```

### Export Metrics (Prometheus)

Enable ServiceMonitor in values:
```yaml
serviceMonitor:
  enabled: true
  interval: 30s
```

---

## 🎯 Production Checklist

- [ ] Metrics Server installed
- [ ] Ingress Controller installed (nginx)
- [ ] cert-manager installed (for TLS)
- [ ] All secrets created
- [ ] Production values reviewed
- [ ] Resource limits appropriate
- [ ] HPA min/max replicas set
- [ ] PDB minAvailable set
- [ ] Redis persistence enabled
- [ ] Ingress TLS configured
- [ ] Monitoring enabled
- [ ] Backup strategy for Redis
- [ ] Disaster recovery plan

---

## 📚 Additional Resources

- **Helm Chart README:** `helm/cloudops/README.md`
- **Values Reference:** `helm/cloudops/values.yaml`
- **Production Config:** `helm/cloudops/values-production.yaml`
- **Development Config:** `helm/cloudops/values-development.yaml`

---

🎉 **Your Helm chart is production-ready with HPA and PDB!**
