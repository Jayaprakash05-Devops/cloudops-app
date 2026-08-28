# ChatOps Bot Helm Chart

ChatOps Bot Service - Chat-based operations, Slack/Discord integration.

## Installation

```bash
helm install chatops-bot ./chatops-bot
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `service.port` | Service port | `8005` |
