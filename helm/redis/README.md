# CloudOps Redis Helm Chart

Shared Redis instance for all CloudOps services.

## Installation

```bash
helm install cloudops-redis ./redis
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.auth.enabled` | Enable authentication | `false` |
| `redis.master.persistence.size` | Storage size | `8Gi` |
