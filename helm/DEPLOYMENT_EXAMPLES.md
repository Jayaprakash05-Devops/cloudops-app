# 🚀 Independent Charts - Deployment Examples

## ✅ Charts Fixed and Ready!

All independent charts are now **production-ready** for standalone deployment!

---

## 📦 What's Ready

### Independent Service Charts (All Working ✅)
- ✅ **cost-optimizer** - Port 8001
- ✅ **k8s-manager** - Port 8002 (with RBAC)
- ✅ **incident-manager** - Port 8003
- ✅ **automation-service** - Port 8004
- ✅ **chatops-bot** - Port 8005
- ✅ **metrics-collector** - Port 8006
- ✅ **auth-service** - Port 8007 (with Secret)
- ✅ **frontend** - Port 3000 (with Ingress)

### Shared Infrastructure Charts (Correct ✅)
- ✅ **redis** - Shared Redis instance
- ✅ **cloudops-umbrella** - Deploy all services together
- ✅ **cloudops** - Original monolithic chart

---

## 🚀 Deployment Examples

### Example 1: Deploy Single Service

```bash
# Deploy cost-optimizer with embedded Redis
helm install cost-optimizer ./cost-optimizer

# Verify
kubectl get pods
kubectl get svc
kubectl get hpa
```

### Example 2: Deploy Multiple Services

```bash
# Deploy the services you need
helm install cost-optimizer ./cost-optimizer
helm install auth-service ./auth-service \
  --set jwtSecretKey="$(openssl rand -base64 32)"
helm install frontend ./frontend

# Check all deployments
helm list
```

### Example 3: Deploy with Shared Redis (Recommended)

```bash
# 1. Deploy shared Redis once
helm install cloudops-redis ./redis

# 2. Deploy services pointing to shared Redis
helm install cost-optimizer ./cost-optimizer \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

helm install auth-service ./auth-service \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master \
  --set jwtSecretKey="$(openssl rand -base64 32)"

helm install k8s-manager ./k8s-manager \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

helm install frontend ./frontend
```

### Example 4: Production Deployment

```bash
# Generate secure JWT key
JWT_KEY=$(openssl rand -base64 32)

# Deploy shared Redis with persistence
helm install cloudops-redis ./redis \
  --set redis.master.persistence.size=20Gi \
  --set redis.replica.replicaCount=2

# Deploy backend services with HA
for service in cost-optimizer k8s-manager incident-manager automation-service chatops-bot metrics-collector; do
  helm install $service ./$service \
    --set redis.enabled=false \
    --set env[0].value=cloudops-redis-master \
    --set replicaCount=3 \
    --set autoscaling.minReplicas=3 \
    --set autoscaling.maxReplicas=15
done

# Deploy auth service with secure JWT key
helm install auth-service ./auth-service \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master \
  --set jwtSecretKey="${JWT_KEY}" \
  --set replicaCount=3

# Deploy frontend with ingress
helm install frontend ./frontend \
  --set replicaCount=5 \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=cloudops.yourdomain.com \
  --set ingress.tls[0].secretName=cloudops-tls \
  --set ingress.tls[0].hosts[0]=cloudops.yourdomain.com
```

### Example 5: Development Environment

```bash
# Quick dev setup with embedded Redis
helm install cost-optimizer ./cost-optimizer \
  --set replicaCount=1 \
  --set autoscaling.enabled=false

helm install auth-service ./auth-service \
  --set replicaCount=1 \
  --set autoscaling.enabled=false \
  --set jwtSecretKey="dev-secret-key"

helm install frontend ./frontend \
  --set replicaCount=1 \
  --set autoscaling.enabled=false
```

### Example 6: Selective Deployment

```bash
# Deploy only cost optimizer and frontend
helm install cloudops-redis ./redis
helm install cost-optimizer ./cost-optimizer --set redis.enabled=false
helm install frontend ./frontend
```

### Example 7: Multi-Namespace Deployment

```bash
# Core services in 'core' namespace
kubectl create namespace core
helm install cloudops-redis ./redis -n core
helm install auth-service ./auth-service -n core \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

# Backend services in 'backend' namespace
kubectl create namespace backend
helm install cost-optimizer ./cost-optimizer -n backend \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master.core.svc.cluster.local

helm install k8s-manager ./k8s-manager -n backend \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master.core.svc.cluster.local

# Frontend in 'frontend' namespace
kubectl create namespace frontend
helm install frontend ./frontend -n frontend
```

---

## 🧪 Testing Deployments

### Test Individual Service

```bash
# Port forward
kubectl port-forward svc/cost-optimizer 8001:8001

# Test endpoint
curl http://localhost:8001/health
curl http://localhost:8001/costs/summary
```

### Test Auth Service

```bash
# Port forward
kubectl port-forward svc/auth-service 8007:8007

# Test login
curl -X POST http://localhost:8007/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Test Frontend

```bash
# Port forward
kubectl port-forward svc/frontend 3000:3000

# Open browser
open http://localhost:3000
```

---

## 📊 Scaling Examples

### Manual Scaling

```bash
# Scale via kubectl
kubectl scale deployment cost-optimizer --replicas=5

# Scale via helm upgrade
helm upgrade cost-optimizer ./cost-optimizer \
  --reuse-values \
  --set replicaCount=5
```

### Auto-Scaling (Already Configured)

Each service has HPA enabled by default:
- Min replicas: 2
- Max replicas: 10
- Target CPU: 70%
- Target Memory: 80%

```bash
# View HPA status
kubectl get hpa

# Watch auto-scaling
kubectl get hpa -w
```

---

## 🔄 Update Examples

### Update Single Service

```bash
# Update to new version
helm upgrade cost-optimizer ./cost-optimizer \
  --set image.tag=1.1.0

# Update configuration
helm upgrade cost-optimizer ./cost-optimizer \
  --reuse-values \
  --set resources.limits.memory=2Gi
```

### Update All Services

```bash
# Update all to new version
for service in cost-optimizer k8s-manager incident-manager automation-service chatops-bot metrics-collector auth-service frontend; do
  helm upgrade $service ./$service \
    --reuse-values \
    --set image.tag=1.1.0
done
```

---

## 🗑️ Cleanup Examples

### Remove Single Service

```bash
helm uninstall cost-optimizer
```

### Remove All Services

```bash
# List all releases
helm list

# Uninstall all
helm list --short | xargs -L1 helm uninstall
```

### Remove Specific Namespace

```bash
# Remove all in namespace
helm list -n backend --short | xargs -L1 helm uninstall -n backend

# Delete namespace
kubectl delete namespace backend
```

---

## 🔍 Verification Commands

### Check Deployment Status

```bash
# List all Helm releases
helm list

# Check pods
kubectl get pods

# Check services
kubectl get svc

# Check HPA
kubectl get hpa

# Check PDB
kubectl get pdb

# Check all resources for a service
kubectl get all -l app.kubernetes.io/name=cost-optimizer
```

### Check Logs

```bash
# View logs
kubectl logs -l app.kubernetes.io/name=cost-optimizer

# Follow logs
kubectl logs -f -l app.kubernetes.io/name=cost-optimizer

# View last 50 lines
kubectl logs --tail=50 -l app.kubernetes.io/name=cost-optimizer
```

### Check Events

```bash
# Recent events
kubectl get events --sort-by='.lastTimestamp'

# Events for specific deployment
kubectl describe deployment cost-optimizer
```

---

## ⚙️ Configuration Examples

### Override Resources

```bash
helm install cost-optimizer ./cost-optimizer \
  --set resources.limits.cpu=2000m \
  --set resources.limits.memory=2Gi \
  --set resources.requests.cpu=1000m \
  --set resources.requests.memory=1Gi
```

### Override Autoscaling

```bash
helm install cost-optimizer ./cost-optimizer \
  --set autoscaling.minReplicas=5 \
  --set autoscaling.maxReplicas=20 \
  --set autoscaling.targetCPUUtilizationPercentage=60
```

### Use Custom Values File

```bash
# Create values file
cat > my-values.yaml << EOF
replicaCount: 3
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
autoscaling:
  minReplicas: 3
  maxReplicas: 15
redis:
  enabled: false
env:
  - name: REDIS_HOST
    value: my-redis-host
EOF

# Deploy with custom values
helm install cost-optimizer ./cost-optimizer \
  -f my-values.yaml
```

---

## 🎯 Common Scenarios

### Scenario: Add New Service to Existing Deployment

```bash
# Already have some services running
# Add metrics-collector
helm install metrics-collector ./metrics-collector \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master
```

### Scenario: Migrate from Monolithic to Independent

```bash
# Step 1: Note current configuration
helm get values cloudops > current-values.yaml

# Step 2: Uninstall monolithic
helm uninstall cloudops

# Step 3: Deploy services independently
helm install cloudops-redis ./redis
helm install cost-optimizer ./cost-optimizer --set redis.enabled=false
# ... deploy other services
```

### Scenario: Rollback Failed Upgrade

```bash
# Check history
helm history cost-optimizer

# Rollback to previous version
helm rollback cost-optimizer

# Rollback to specific revision
helm rollback cost-optimizer 2
```

---

## 📝 Best Practices

### For Production

1. **Use shared Redis**
   ```bash
   helm install cloudops-redis ./redis
   # Then deploy services with redis.enabled=false
   ```

2. **Set resource limits**
   ```bash
   --set resources.limits.cpu=1000m
   --set resources.limits.memory=1Gi
   ```

3. **Enable HA with multiple replicas**
   ```bash
   --set replicaCount=3
   --set autoscaling.minReplicas=3
   ```

4. **Use secrets management**
   ```bash
   --set jwtSecretKey="$(openssl rand -base64 32)"
   ```

5. **Enable ingress with TLS**
   ```bash
   --set ingress.enabled=true
   --set ingress.tls[0].secretName=my-tls-secret
   ```

### For Development

1. **Use embedded Redis** (default)
2. **Single replica** (`--set replicaCount=1`)
3. **Disable autoscaling** (`--set autoscaling.enabled=false`)
4. **Port-forward for access** (no ingress needed)

---

## 🎉 Summary

All independent charts are now ready! You can:

✅ **Deploy any service independently**  
✅ **Deploy services with shared or embedded Redis**  
✅ **Scale services independently**  
✅ **Update services independently**  
✅ **Configure each service separately**  
✅ **Use in any Kubernetes cluster**  

**Choose the deployment example that fits your needs!**
