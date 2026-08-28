# 🔧 ArgoCD Troubleshooting Guide

Common issues and solutions for ArgoCD deployments.

---

## 📋 Table of Contents

- [Application Issues](#application-issues)
- [Sync Issues](#sync-issues)
- [Health Issues](#health-issues)
- [Repository Issues](#repository-issues)
- [Resource Issues](#resource-issues)
- [Network Issues](#network-issues)
- [Performance Issues](#performance-issues)

---

## 🚨 Application Issues

### Application Stuck in "Progressing"

**Symptom:** Application shows "Progressing" for extended time

**Check:**
```bash
kubectl describe application <app-name> -n argocd
kubectl get pods -n cloudops -l app.kubernetes.io/name=<app-name>
```

**Solutions:**

1. **Check pod status:**
   ```bash
   kubectl describe pod <pod-name> -n cloudops
   ```

2. **Check image pull:**
   ```bash
   kubectl get events -n cloudops --sort-by='.lastTimestamp' | grep -i pull
   ```

3. **Check resources:**
   ```bash
   kubectl top nodes
   kubectl top pods -n cloudops
   ```

4. **Force sync:**
   ```bash
   kubectl patch application <app-name> -n argocd \
     --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"prune":true}}}'
   ```

### Application Shows "Degraded"

**Symptom:** Application health status is "Degraded"

**Check:**
```bash
kubectl get application <app-name> -n argocd -o yaml | grep -A 10 status
```

**Solutions:**

1. **Check pod health:**
   ```bash
   kubectl get pods -n cloudops -l app.kubernetes.io/name=<app-name>
   kubectl logs -n cloudops -l app.kubernetes.io/name=<app-name> --tail=50
   ```

2. **Check readiness probes:**
   ```bash
   kubectl describe pod <pod-name> -n cloudops | grep -A 5 Readiness
   ```

3. **Check service endpoints:**
   ```bash
   kubectl get endpoints -n cloudops <service-name>
   ```

4. **Restart pods:**
   ```bash
   kubectl rollout restart deployment <deployment-name> -n cloudops
   ```

### Application "Missing" Resources

**Symptom:** Application status shows "Missing" resources

**Check:**
```bash
kubectl get application <app-name> -n argocd -o jsonpath='{.status.resources}'
```

**Solutions:**

1. **Check namespace exists:**
   ```bash
   kubectl get namespace cloudops
   ```

2. **Recreate namespace if needed:**
   ```bash
   kubectl create namespace cloudops
   ```

3. **Re-sync application:**
   ```bash
   kubectl patch application <app-name> -n argocd \
     --type merge -p '{"operation":{"sync":{}}}'
   ```

---

## 🔄 Sync Issues

### Application Won't Sync

**Symptom:** Manual sync fails or hangs

**Check:**
```bash
kubectl describe application <app-name> -n argocd
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

**Solutions:**

1. **Terminate stuck operation:**
   ```bash
   kubectl patch application <app-name> -n argocd \
     --type merge -p '{"operation":null}'
   ```

2. **Delete and recreate application:**
   ```bash
   kubectl delete application <app-name> -n argocd
   kubectl apply -f argocd/applications/<app-name>.yaml
   ```

3. **Check API server:**
   ```bash
   kubectl cluster-info
   kubectl get --raw /healthz
   ```

### "OutOfSync" Status Persists

**Symptom:** Application always shows "OutOfSync"

**Check:**
```bash
kubectl get application <app-name> -n argocd -o jsonpath='{.status.sync}'
```

**Solutions:**

1. **Check ignore differences:**
   ```yaml
   ignoreDifferences:
     - group: apps
       kind: Deployment
       jsonPointers:
         - /spec/replicas  # Ignore HPA-managed replicas
   ```

2. **Force replace:**
   ```bash
   kubectl patch application <app-name> -n argocd \
     --type merge -p '{"operation":{"sync":{"syncOptions":["Replace=true"]}}}'
   ```

3. **Prune resources:**
   ```bash
   kubectl patch application <app-name> -n argocd \
     --type merge -p '{"operation":{"sync":{"prune":true}}}'
   ```

### Sync Fails with "Permission Denied"

**Symptom:** Sync operation fails with RBAC errors

**Check:**
```bash
kubectl describe appproject cloudops -n argocd
```

**Solutions:**

1. **Update AppProject permissions:**
   ```yaml
   spec:
     clusterResourceWhitelist:
       - group: '*'
         kind: '*'
   ```

2. **Check ArgoCD service account:**
   ```bash
   kubectl get serviceaccount argocd-application-controller -n argocd
   kubectl describe clusterrolebinding argocd-application-controller
   ```

---

## 💚 Health Issues

### Custom Health Checks Failing

**Symptom:** Application shows unhealthy despite pods running

**Check:**
```bash
kubectl get application <app-name> -n argocd -o jsonpath='{.status.health}'
```

**Solutions:**

1. **Check health assessment:**
   ```bash
   kubectl describe application <app-name> -n argocd | grep -A 20 Health
   ```

2. **Add custom health check:**
   ```yaml
   # In argocd-cm ConfigMap
   resource.customizations.health.<group>_<kind>: |
     hs = {}
     if obj.status ~= nil then
       if obj.status.conditions ~= nil then
         for i, condition in ipairs(obj.status.conditions) do
           if condition.type == "Ready" and condition.status == "False" then
             hs.status = "Degraded"
             hs.message = condition.message
             return hs
           end
         end
       end
     end
     hs.status = "Healthy"
     return hs
   ```

3. **Disable health checks temporarily:**
   ```yaml
   spec:
     ignoreDifferences:
       - group: "*"
         kind: "*"
         managedFieldsManagers:
           - HealthStatus
   ```

---

## 📦 Repository Issues

### Cannot Connect to Repository

**Symptom:** "Repository not found" or connection timeout

**Check:**
```bash
kubectl get secret -n argocd | grep repo
kubectl describe application <app-name> -n argocd | grep -i repo
```

**Solutions:**

1. **Verify repository URL:**
   ```bash
   git ls-remote https://github.com/yourusername/cloudops.git
   ```

2. **Add repository with credentials:**
   ```bash
   # For HTTPS with token
   kubectl create secret generic repo-credentials -n argocd \
     --from-literal=type=git \
     --from-literal=url=https://github.com/yourusername/cloudops.git \
     --from-literal=username=YOUR_USERNAME \
     --from-literal=password=YOUR_TOKEN
   
   # Label the secret
   kubectl label secret repo-credentials -n argocd \
     argocd.argoproj.io/secret-type=repository
   ```

3. **For private repositories with SSH:**
   ```bash
   # Generate SSH key
   ssh-keygen -t ed25519 -f ~/.ssh/argocd -N ""
   
   # Add public key to GitHub
   # Then create secret
   kubectl create secret generic argocd-ssh-key -n argocd \
     --from-file=sshPrivateKey=$HOME/.ssh/argocd
   
   kubectl label secret argocd-ssh-key -n argocd \
     argocd.argoproj.io/secret-type=repository
   ```

### "ComparisonError" with Helm Chart

**Symptom:** Failed to load target state: Helm template error

**Check:**
```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-repo-server --tail=100
```

**Solutions:**

1. **Test Helm chart locally:**
   ```bash
   cd helm/cost-optimizer
   helm template test . --debug
   helm lint .
   ```

2. **Check values syntax:**
   ```bash
   # Validate YAML
   yq eval '.' helm/cost-optimizer/values.yaml
   ```

3. **Check Chart.yaml version:**
   ```yaml
   apiVersion: v2  # Use v2 for Helm 3
   name: cost-optimizer
   version: 1.0.0
   ```

---

## 🔧 Resource Issues

### Insufficient Resources

**Symptom:** Pods stuck in "Pending" state

**Check:**
```bash
kubectl describe pod <pod-name> -n cloudops | grep -i "insufficient"
kubectl top nodes
```

**Solutions:**

1. **Scale cluster:**
   ```bash
   # Minikube
   minikube stop
   minikube start --cpus=6 --memory=12288
   
   # Or add nodes to existing cluster
   ```

2. **Reduce resource requests:**
   ```yaml
   # In application values
   resources:
     requests:
       cpu: 100m
       memory: 128Mi
     limits:
       cpu: 500m
       memory: 512Mi
   ```

3. **Disable autoscaling temporarily:**
   ```yaml
   autoscaling:
     enabled: false
   ```

### PVC Binding Issues

**Symptom:** PersistentVolumeClaim stuck in "Pending"

**Check:**
```bash
kubectl describe pvc <pvc-name> -n cloudops
kubectl get storageclass
```

**Solutions:**

1. **Check storage class exists:**
   ```bash
   kubectl get storageclass
   ```

2. **Create default storage class:**
   ```bash
   kubectl patch storageclass standard \
     -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
   ```

3. **For Minikube:**
   ```bash
   minikube addons enable storage-provisioner
   ```

---

## 🌐 Network Issues

### Service Not Accessible

**Symptom:** Cannot reach service via port-forward or ingress

**Check:**
```bash
kubectl get svc -n cloudops
kubectl get endpoints -n cloudops
kubectl describe ingress -n cloudops
```

**Solutions:**

1. **Check service endpoints:**
   ```bash
   kubectl get endpoints <service-name> -n cloudops
   ```

2. **Test pod directly:**
   ```bash
   kubectl port-forward pod/<pod-name> -n cloudops 8001:8001
   curl http://localhost:8001/health
   ```

3. **Check ingress controller:**
   ```bash
   kubectl get pods -n ingress-nginx
   kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
   ```

### DNS Resolution Issues

**Symptom:** Services cannot communicate with each other

**Check:**
```bash
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Inside pod:
nslookup cost-optimizer.cloudops.svc.cluster.local
```

**Solutions:**

1. **Check CoreDNS:**
   ```bash
   kubectl get pods -n kube-system -l k8s-app=kube-dns
   kubectl logs -n kube-system -l k8s-app=kube-dns
   ```

2. **Restart CoreDNS:**
   ```bash
   kubectl rollout restart deployment coredns -n kube-system
   ```

---

## ⚡ Performance Issues

### Slow Sync Operations

**Symptom:** Sync takes very long to complete

**Check:**
```bash
kubectl top pods -n argocd
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

**Solutions:**

1. **Increase ArgoCD resources:**
   ```bash
   kubectl patch deployment argocd-application-controller -n argocd \
     --type merge -p '{"spec":{"template":{"spec":{"containers":[{"name":"argocd-application-controller","resources":{"requests":{"cpu":"500m","memory":"1Gi"},"limits":{"cpu":"2000m","memory":"2Gi"}}}]}}}}'
   ```

2. **Reduce sync frequency:**
   ```yaml
   # In application
   spec:
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
       syncOptions:
         - ApplyOutOfSyncOnly=true
   ```

3. **Use server-side apply:**
   ```yaml
   syncOptions:
     - ServerSideApply=true
   ```

### ArgoCD API Slow

**Symptom:** ArgoCD UI very slow or unresponsive

**Check:**
```bash
kubectl top pod -n argocd -l app.kubernetes.io/name=argocd-server
```

**Solutions:**

1. **Scale ArgoCD server:**
   ```bash
   kubectl scale deployment argocd-server -n argocd --replicas=3
   ```

2. **Increase Redis resources:**
   ```bash
   kubectl patch deployment argocd-redis -n argocd \
     --type merge -p '{"spec":{"template":{"spec":{"containers":[{"name":"redis","resources":{"limits":{"memory":"512Mi"}}}]}}}}'
   ```

---

## 🔍 Diagnostic Commands

### Full Application Status

```bash
#!/bin/bash
APP_NAME=$1

echo "=== Application Status ==="
kubectl get application $APP_NAME -n argocd

echo -e "\n=== Sync Status ==="
kubectl get application $APP_NAME -n argocd -o jsonpath='{.status.sync.status}'

echo -e "\n\n=== Health Status ==="
kubectl get application $APP_NAME -n argocd -o jsonpath='{.status.health.status}'

echo -e "\n\n=== Resources ==="
kubectl get pods,svc,hpa,pdb -n cloudops -l app.kubernetes.io/name=$APP_NAME

echo -e "\n=== Recent Events ==="
kubectl get events -n cloudops --sort-by='.lastTimestamp' | grep $APP_NAME | tail -10

echo -e "\n=== Recent Logs ==="
kubectl logs -n cloudops -l app.kubernetes.io/name=$APP_NAME --tail=20
```

### Check All Applications

```bash
#!/bin/bash

echo "=== All Applications ==="
kubectl get applications -n argocd

echo -e "\n=== Sync Status ==="
kubectl get applications -n argocd -o custom-columns=\
NAME:.metadata.name,\
SYNC:.status.sync.status,\
HEALTH:.status.health.status,\
REVISION:.status.sync.revision

echo -e "\n=== Pods Status ==="
kubectl get pods -n cloudops -o wide

echo -e "\n=== Services ==="
kubectl get svc -n cloudops

echo -e "\n=== HPA Status ==="
kubectl get hpa -n cloudops
```

---

## 📞 Getting Help

### Collect Diagnostics

```bash
# ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server > argocd-server.log
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller > argocd-controller.log
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-repo-server > argocd-repo.log

# Application status
kubectl get applications -n argocd -o yaml > applications.yaml

# Cluster info
kubectl cluster-info dump > cluster-info.txt
```

### Useful Resources

- **ArgoCD Docs:** https://argo-cd.readthedocs.io/
- **GitHub Issues:** https://github.com/argoproj/argo-cd/issues
- **Slack:** https://argoproj.github.io/community/join-slack
- **CloudOps Docs:** `../docs/README.md`

---

## ✅ Prevention Checklist

- [ ] Test Helm charts locally before committing
- [ ] Use proper RBAC and projects
- [ ] Set appropriate resource limits
- [ ] Configure health checks correctly
- [ ] Use ignore differences for HPA
- [ ] Enable notifications for failures
- [ ] Monitor ArgoCD resource usage
- [ ] Regular backup of Git repository
- [ ] Document custom configurations
- [ ] Keep ArgoCD updated

---

**Still having issues?** Check the [main README](README.md) or [Kubernetes deployment guide](../docs/KUBERNETES_HELM_DEPLOYMENT.md).
