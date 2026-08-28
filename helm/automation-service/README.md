# Automation Service Helm Chart

DevOps Automation Service - CI/CD pipelines, infrastructure provisioning.

## Installation

```bash
helm install automation-service ./automation-service
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `service.port` | Service port | `8004` |
