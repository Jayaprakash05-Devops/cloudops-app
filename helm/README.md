# CloudOps Helm Charts

Independent Helm charts for each CloudOps microservice.

## 📁 Chart Structure

```
helm/
├── cost-optimizer/        # Port 8001 - Cost optimization service
├── k8s-manager/           # Port 8002 - Kubernetes management
├── incident-manager/      # Port 8003 - Incident management
├── automation-service/    # Port 8004 - DevOps automation
├── chatops-bot/           # Port 8005 - ChatOps interface
├── metrics-collector/     # Port 8006 - Metrics collection
├── auth-service/          # Port 8007 - Authentication
├── frontend/              # Port 3000 - Web dashboard
├── redis/                 # Redis (shared dependency)
└── cloudops-umbrella/     # Deploy all services together (optional)
```

## 🚀 Quick Start

### Option 1: Deploy All Services (Umbrella Chart)

```bash
# Deploy everything at once
helm install cloudops ./cloudops-umbrella
```

### Option 2: Deploy Individual Services

```bash
# Deploy only the services you need

# 1. Deploy shared Redis (optional if using external Redis)
helm install cloudops-redis ./redis

# 2. Deploy authentication
helm install auth-service ./auth-service \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

# 3. Deploy backend services
helm install cost-optimizer ./cost-optimizer --set redis.enabled=false
helm install k8s-manager ./k8s-manager --set redis.enabled=false
helm install incident-manager ./incident-manager --set redis.enabled=false

# 4. Deploy frontend
helm install frontend ./frontend
```

## 📊 Service Dependencies

### With Embedded Redis (Default)
Each service deploys its own Redis instance:

```bash
helm install cost-optimizer ./cost-optimizer
# This installs: cost-optimizer + redis
```

### With Shared Redis (Recommended for Production)
Deploy Redis once and share across services:

```bash
# 1. Deploy shared Redis
helm install cloudops-redis ./redis

# 2. Deploy services without Redis
helm install cost-optimizer ./cost-optimizer \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

helm install auth-service ./auth-service \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master
```

## 🔧 Configuration

### Common Parameters

All backend services support these parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `image.tag` | Image tag | `1.0.0` |
| `autoscaling.enabled` | Enable HPA | `true` |
| `autoscaling.minReplicas` | Min replicas | `2` |
| `autoscaling.maxReplicas` | Max replicas | `10` |
| `podDisruptionBudget.enabled` | Enable PDB | `true` |
| `redis.enabled` | Deploy Redis with chart | `true` |

### Service-Specific Parameters

#### Cost Optimizer
```bash
helm install cost-optimizer ./cost-optimizer \
  --set replicaCount=3 \
  --set resources.limits.memory=1Gi
```

#### K8s Manager (Needs RBAC)
```bash
helm install k8s-manager ./k8s-manager \
  --set rbac.create=true \
  --set serviceAccount.create=true
```

#### Auth Service (Needs JWT Secret)
```bash
JWT_KEY=$(openssl rand -base64 32)
helm install auth-service ./auth-service \
  --set jwtSecretKey="${JWT_KEY}"
```

#### Frontend (With Ingress)
```bash
helm install frontend ./frontend \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=cloudops.yourdomain.com
```

## 🎯 Deployment Scenarios

### Scenario 1: Full Platform (Development)

Deploy everything with embedded Redis:

```bash
# Simple - each service gets its own Redis
for service in cost-optimizer k8s-manager incident-manager automation-service chatops-bot metrics-collector auth-service frontend; do
  helm install $service ./$service
done
```

### Scenario 2: Full Platform (Production)

Deploy with shared Redis and HA:

```bash
# 1. Deploy shared Redis
helm install cloudops-redis ./redis \
  --set redis.auth.enabled=true \
  --set redis.master.persistence.size=20Gi

# 2. Deploy services
for service in cost-optimizer k8s-manager incident-manager automation-service chatops-bot metrics-collector auth-service; do
  helm install $service ./$service \
    --set redis.enabled=false \
    --set env[0].value=cloudops-redis-master \
    --set replicaCount=3 \
    --set autoscaling.minReplicas=3
done

# 3. Deploy frontend with ingress
helm install frontend ./frontend \
  --set replicaCount=5 \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=cloudops.yourdomain.com
```

### Scenario 3: Selective Deployment

Deploy only what you need:

```bash
# Just cost optimizer and frontend
helm install cloudops-redis ./redis
helm install cost-optimizer ./cost-optimizer --set redis.enabled=false
helm install frontend ./frontend
```

### Scenario 4: Multi-Namespace Deployment

Deploy services across different namespaces:

```bash
# Core services in 'core' namespace
kubectl create namespace core
helm install auth-service ./auth-service -n core
helm install cloudops-redis ./redis -n core

# Backend services in 'backend' namespace
kubectl create namespace backend
helm install cost-optimizer ./cost-optimizer -n backend \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master.core.svc.cluster.local

# Frontend in 'frontend' namespace
kubectl create namespace frontend
helm install frontend ./frontend -n frontend
```

## 📦 Chart Dependencies

### Dependency Matrix

| Service | Depends On | Optional |
|---------|-----------|----------|
| cost-optimizer | Redis | Yes |
| k8s-manager | Redis | Yes |
| incident-manager | Redis | Yes |
| automation-service | Redis | Yes |
| chatops-bot | Redis | Yes |
| metrics-collector | Redis | Yes |
| auth-service | Redis | Yes |
| frontend | Backend Services | Yes |

### Building Dependencies

```bash
# Update dependencies for a chart
cd cost-optimizer
helm dependency update
```

## 🔍 Verification

### Check Deployment Status

```bash
# List all deployments
helm list

# Check specific service
kubectl get all -l app.kubernetes.io/name=cost-optimizer

# Check HPA
kubectl get hpa

# Check PDB
kubectl get pdb
```

### Test Services

```bash
# Port forward to test
kubectl port-forward svc/cost-optimizer 8001:8001
kubectl port-forward svc/auth-service 8007:8007
kubectl port-forward svc/frontend 3000:3000

# Test endpoints
curl http://localhost:8001/health
curl http://localhost:8007/health
open http://localhost:3000
```

## 📈 Scaling

### Manual Scaling

```bash
# Scale specific service
kubectl scale deployment cost-optimizer --replicas=5

# Or via helm upgrade
helm upgrade cost-optimizer ./cost-optimizer \
  --set replicaCount=5
```

### Auto-Scaling (HPA)

Already configured by default:
- Min replicas: 2
- Max replicas: 10
- Target CPU: 70%
- Target Memory: 80%

## 🔄 Updates

### Update Individual Service

```bash
# Update cost-optimizer to new version
helm upgrade cost-optimizer ./cost-optimizer \
  --set image.tag=1.1.0
```

### Update All Services

```bash
for service in cost-optimizer k8s-manager incident-manager automation-service chatops-bot metrics-collector auth-service frontend; do
  helm upgrade $service ./$service --set image.tag=1.1.0
done
```

## 🗑️ Uninstall

### Remove Individual Service

```bash
helm uninstall cost-optimizer
```

### Remove All Services

```bash
helm list --short | xargs -n1 helm uninstall
```

## 🎓 Best Practices

### Production Deployment

1. **Use Shared Redis**
   - Deploy one Redis instance
   - Point all services to it
   - Enable authentication

2. **Set Resource Limits**
   - Configure appropriate CPU/memory limits
   - Enable HPA for auto-scaling

3. **Enable PDB**
   - Ensure high availability
   - Protect against disruptions

4. **Use Ingress**
   - Enable TLS
   - Configure proper hostnames

5. **Secure Secrets**
   - Use external secret management
   - Rotate JWT keys regularly

### Development Deployment

1. **Use Embedded Redis**
   - Each service gets its own Redis
   - Easier to develop and test

2. **Lower Resource Limits**
   - Reduce CPU/memory requests
   - Disable HPA if needed

3. **Port Forward**
   - Access services locally
   - No ingress needed

## 📝 Examples

See individual chart READMEs for detailed examples:
- [cost-optimizer/README.md](cost-optimizer/README.md)
- [k8s-manager/README.md](k8s-manager/README.md)
- [auth-service/README.md](auth-service/README.md)
- [frontend/README.md](frontend/README.md)

## 🆘 Troubleshooting

### Service Won't Start

```bash
# Check pods
kubectl get pods -l app.kubernetes.io/name=cost-optimizer

# Check logs
kubectl logs -l app.kubernetes.io/name=cost-optimizer

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Redis Connection Issues

```bash
# Check Redis is running
kubectl get pods -l app.kubernetes.io/name=redis

# Test Redis connection
kubectl run redis-test --rm -it --image=redis:7-alpine -- redis-cli -h cloudops-redis-master ping
```

### HPA Not Scaling

```bash
# Check HPA status
kubectl get hpa cost-optimizer -o yaml

# Check metrics-server
kubectl top pods
```

## 📚 Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [CloudOps Documentation](../docs/)

---

**🎉 You can now deploy CloudOps services independently!**

Choose the deployment scenario that fits your needs:
- **All services**: Use umbrella chart
- **Selective**: Deploy only what you need
- **Multi-namespace**: Separate by concern
- **Development**: Embedded Redis
- **Production**: Shared Redis + HA
