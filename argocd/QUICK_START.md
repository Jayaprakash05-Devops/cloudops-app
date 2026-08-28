# ⚡ ArgoCD Quick Start Guide

Get CloudOps running with ArgoCD in 5 minutes!

---

## 🎯 Prerequisites

- Kubernetes cluster running
- `kubectl` configured
- ArgoCD installed

---

## 🚀 5-Minute Setup

### Step 1: Install ArgoCD (2 minutes)

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
```

### Step 2: Configure Repository (1 minute)

```bash
# Update Git repository URL in all manifests
export GIT_REPO="https://github.com/YOUR_USERNAME/cloudops.git"

cd argocd/
find . -name "*.yaml" -type f -exec sed -i \
  "s|https://github.com/yourusername/cloudops.git|${GIT_REPO}|g" {} \;
```

### Step 3: Deploy CloudOps (2 minutes)

```bash
# Create project
kubectl apply -f appproject.yaml

# Deploy all services via parent app
kubectl apply -f app-of-apps/cloudops-parent.yaml

# Watch deployment
kubectl get applications -n argocd -w
```

---

## 🎛️ Access ArgoCD UI

```bash
# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Open browser
open https://localhost:8080

# Login:
# Username: admin
# Password: (from Step 1)
```

---

## 📊 Monitor Status

```bash
# Check applications
kubectl get applications -n argocd

# Check pods
kubectl get pods -n cloudops

# Check services
kubectl get svc -n cloudops

# Access frontend
kubectl port-forward svc/frontend -n cloudops 3000:3000
open http://localhost:3000
```

---

## 🔄 Common Operations

### Sync Application

```bash
# Sync via kubectl
kubectl patch application cost-optimizer -n argocd \
  --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{}}}'

# Or install ArgoCD CLI
argocd app sync cost-optimizer
```

### View Application

```bash
# Get status
kubectl get application cost-optimizer -n argocd

# Describe
kubectl describe application cost-optimizer -n argocd
```

### Update Configuration

```bash
# Edit application
kubectl edit application cost-optimizer -n argocd

# Or update file and apply
vim applications/cost-optimizer.yaml
kubectl apply -f applications/cost-optimizer.yaml
```

---

## 🗑️ Cleanup

```bash
# Delete parent app (removes all services)
kubectl delete application cloudops-parent -n argocd

# Delete project
kubectl delete appproject cloudops -n argocd

# Uninstall ArgoCD
kubectl delete namespace argocd
```

---

## 🎯 Next Steps

1. **Customize Configuration**
   - Edit `applications/*.yaml` files
   - Update Helm values
   - Configure ingress domains

2. **Set Up Production**
   - Update JWT secret key
   - Configure TLS certificates
   - Set up monitoring

3. **Read Full Documentation**
   - [ArgoCD README](README.md)
   - [Kubernetes Deployment Guide](../docs/KUBERNETES_HELM_DEPLOYMENT.md)
   - [Helm Documentation](../helm/README.md)

---

## 📚 Quick Reference

### Application Status

```bash
# All apps
kubectl get applications -n argocd

# Specific app
kubectl get application <name> -n argocd -o jsonpath='{.status.sync.status}'
```

### Health Status

```bash
kubectl get application <name> -n argocd -o jsonpath='{.status.health.status}'
```

### Force Sync

```bash
kubectl patch application <name> -n argocd \
  --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"prune":true}}}'
```

### View Logs

```bash
# ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# Application logs
kubectl logs -n cloudops -l app.kubernetes.io/name=cost-optimizer
```

---

## ✅ Success Checklist

- [ ] ArgoCD installed and running
- [ ] Git repository URL updated
- [ ] AppProject created
- [ ] Parent application deployed
- [ ] All applications synced
- [ ] All applications healthy
- [ ] Frontend accessible
- [ ] Can login to CloudOps

---

**You're all set! CloudOps is now running on GitOps! 🎉**

For detailed documentation, see [README.md](README.md)
