# Auth Service Helm Chart

Authentication Service - JWT authentication, user management, RBAC.

## Installation

```bash
# Generate secure JWT key
JWT_KEY=$(openssl rand -base64 32)

helm install auth-service ./auth-service \
  --set jwtSecretKey="${JWT_KEY}"
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `jwtSecretKey` | JWT secret key | `change-this-*` |
| `replicaCount` | Number of replicas | `2` |
| `service.port` | Service port | `8007` |
