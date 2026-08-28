# Learning Guide - Synapse Microservices Platform

This guide will help you understand the architecture, technologies, and DevOps/SRE concepts used in this project.

## Table of Contents
1. [Microservices Architecture](#microservices-architecture)
2. [Service Communication](#service-communication)
3. [Health Checking Strategies](#health-checking-strategies)
4. [Metrics Collection](#metrics-collection)
5. [Alert Management](#alert-management)
6. [Technologies Used](#technologies-used)
7. [Hands-on Exercises](#hands-on-exercises)

## Microservices Architecture

### What is Microservices?
Microservices is an architectural style where an application is built as a collection of small, independent services that:
- Run in their own process
- Communicate via lightweight mechanisms (HTTP/REST)
- Are independently deployable
- Can use different technologies

### Our Architecture

```
┌─────────────────┐
│   Frontend      │  Port 3000
│   (React)       │
└────────┬────────┘
         │
    ┌────┴────┐
    │  API    │
    └────┬────┘
         │
    ┌────┴────────────────────────────┐
    │                                  │
┌───▼────┐  ┌──────────┐  ┌──────────┐  ┌───────────┐
│Service │  │  Health  │  │ Metrics  │  │   Alert   │
│Registry│  │ Checker  │  │Collector │  │  Manager  │
│ 8001   │  │  8002    │  │  8003    │  │   8004    │
└────┬───┘  └─────┬────┘  └─────┬────┘  └─────┬─────┘
     │            │              │              │
     └────────────┴──────────────┴──────────────┘
                       │
                  ┌────▼────┐
                  │  Redis  │
                  │  6379   │
                  └─────────┘
```

### Service Responsibilities

1. **Service Registry (Port 8001)**
   - Service discovery pattern
   - Maintains catalog of all services
   - Provides service lookup
   - **Concept**: Service Discovery

2. **Health Checker (Port 8002)**
   - Performs periodic health checks
   - Monitors service availability
   - Tracks response times
   - **Concept**: Health Monitoring, Proactive Monitoring

3. **Metrics Collector (Port 8003)**
   - Collects performance metrics
   - Aggregates time-series data
   - Calculates statistics (P95, P99)
   - **Concept**: Observability, Metrics

4. **Alert Manager (Port 8004)**
   - Rule-based alerting
   - Threshold monitoring
   - Notification routing
   - **Concept**: Alerting, Incident Management

## Service Communication

### REST APIs
All services expose REST APIs using FastAPI:
- `/health` - Health check endpoint
- Service-specific endpoints for functionality

### Asynchronous Communication
- **Redis Pub/Sub**: For real-time updates
- **Message Queue**: For event-driven updates

### Example: Service Registration Flow

```python
# 1. Client registers a service
POST /register
{
  "service_name": "my-api",
  "service_url": "http://localhost:8000",
  "health_check_endpoint": "/health"
}

# 2. Service Registry stores in Redis
# 3. Health Checker discovers new service
# 4. Health Checker starts monitoring
# 5. Metrics Collector starts collecting data
```

## Health Checking Strategies

### Active vs Passive Monitoring

**Active (What we use)**:
- Proactively checks service health
- Periodic HTTP requests to health endpoints
- Configurable intervals

**Passive**:
- Monitors based on actual traffic
- No additional load on services

### Health States
- **Healthy**: Service responding normally (200 OK)
- **Degraded**: Service responding slowly or with warnings (200-499)
- **Down**: Service not responding or error (500+)

### Implementation
```python
async with httpx.AsyncClient(timeout=5.0) as client:
    response = await client.get(health_check_url)
    if response.status_code == 200:
        status = "healthy"
    elif 200 < response.status_code < 500:
        status = "degraded"
    else:
        status = "down"
```

## Metrics Collection

### Types of Metrics

1. **Response Time**: How long requests take
2. **Error Rate**: Percentage of failed requests
3. **Uptime**: Percentage of time service is available
4. **Throughput**: Requests per second (future enhancement)

### Time-Series Data
Metrics are stored as time-series in Redis:
```
metrics:<service_id>:response_time -> [
  {timestamp: "2024-01-01T12:00:00", value: 0.123},
  {timestamp: "2024-01-01T12:00:30", value: 0.145},
  ...
]
```

### Statistical Analysis
- **Average**: Mean response time
- **Median**: Middle value (50th percentile)
- **P95**: 95th percentile (worst 5% excluded)
- **P99**: 99th percentile (worst 1% excluded)

P95 and P99 are important for SLAs and understanding tail latency.

## Alert Management

### Alert Rules
Define conditions that trigger alerts:
- **Metric**: What to monitor (response_time, error_rate)
- **Condition**: gt (>), lt (<), eq (=)
- **Threshold**: Value to compare against
- **Severity**: warning or critical

### Example Alert Rule
```json
{
  "service_id": "api-service",
  "metric_type": "response_time",
  "condition": "gt",
  "threshold": 1.0,
  "severity": "critical"
}
```

This triggers when response time > 1 second.

### Notification Channels
- Console (stdout)
- Webhook (HTTP POST)
- Slack (future)
- Email (future)

## Technologies Used

### Backend
- **Python 3.11+**: Modern Python with async/await
- **FastAPI**: High-performance async web framework
- **Pydantic**: Data validation using Python type hints
- **Uvicorn**: ASGI server
- **httpx**: Async HTTP client
- **Redis**: In-memory data store for fast access

### Frontend
- **React 18**: Component-based UI library
- **React Router**: Client-side routing
- **Axios**: HTTP client
- **Recharts**: Data visualization library

### Infrastructure
- **Docker**: Containerization
- **Docker Compose**: Multi-container orchestration
- **Redis**: Caching, pub/sub, data storage

## Hands-on Exercises

### Exercise 1: Register and Monitor a Service
```bash
# Start the platform
./scripts/setup.sh

# Register a service
curl -X POST http://localhost:8001/register \
  -H "Content-Type: application/json" \
  -d '{
    "service_name": "my-test-service",
    "service_url": "http://httpbin.org",
    "health_check_endpoint": "/status/200",
    "check_interval": 30
  }'

# Watch it being monitored in the dashboard
open http://localhost:3000
```

### Exercise 2: Create an Alert Rule
```bash
# Get service_id from previous registration
SERVICE_ID="<your-service-id>"

# Create alert for slow response time
curl -X POST http://localhost:8004/rules \
  -H "Content-Type: application/json" \
  -d "{
    \"service_id\": \"$SERVICE_ID\",
    \"metric_type\": \"response_time\",
    \"condition\": \"gt\",
    \"threshold\": 0.5,
    \"severity\": \"warning\"
  }"
```

### Exercise 3: Simulate Service Failure
```bash
# Register a service that will fail
curl -X POST http://localhost:8001/register \
  -H "Content-Type: application/json" \
  -d '{
    "service_name": "failing-service",
    "service_url": "http://httpbin.org",
    "health_check_endpoint": "/status/500",
    "check_interval": 10
  }'

# Watch it be marked as "down" in the dashboard
```

### Exercise 4: View Metrics
1. Go to http://localhost:3000/metrics
2. Select a service
3. Observe:
   - Uptime percentage
   - Average response time
   - Response time graph over time
   - P95/P99 percentiles

### Exercise 5: Extend the Platform
Try adding these features:
1. Add a new metric type (CPU usage, memory)
2. Add a Slack notification channel
3. Add authentication to the APIs
4. Add a database for persistent storage
5. Add service dependencies mapping
6. Add custom dashboards per service

## Key DevOps/SRE Concepts Learned

1. **Service Discovery**: How services find each other
2. **Health Checks**: Monitoring service availability
3. **Observability**: Understanding system behavior through metrics
4. **Alerting**: Proactive notification of issues
5. **SLIs/SLOs**: Service Level Indicators and Objectives
6. **Incident Response**: Alert → Investigation → Resolution
7. **Microservices Patterns**: Registry, Circuit Breaker (future)
8. **Time-Series Data**: Storing and analyzing metrics over time
9. **Distributed Systems**: Inter-service communication
10. **Infrastructure as Code**: Docker Compose configuration

## Next Steps

1. **Add Persistence**: Replace Redis with PostgreSQL for long-term storage
2. **Add Authentication**: Implement JWT-based auth
3. **Add Tracing**: Implement distributed tracing (OpenTelemetry)
4. **Add Logs**: Centralized log aggregation (ELK stack)
5. **Add Kubernetes**: Deploy to Kubernetes cluster
6. **Add CI/CD**: GitHub Actions for automated testing and deployment
7. **Add Dashboards**: Grafana for visualization
8. **Add Service Mesh**: Istio for advanced routing and security

## Resources

- [Microservices.io](https://microservices.io/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://react.dev/)
- [Docker Documentation](https://docs.docker.com/)
- [Site Reliability Engineering Book](https://sre.google/books/)
- [The Twelve-Factor App](https://12factor.net/)

## Troubleshooting

### Services not starting
```bash
# Check logs
docker-compose logs

# Restart services
docker-compose restart

# Rebuild
docker-compose up -d --build
```

### Redis connection issues
```bash
# Check Redis is running
docker ps | grep redis

# Test Redis
docker exec synapse-redis redis-cli ping
```

### Port conflicts
```bash
# Check what's using a port
lsof -i :8001

# Change ports in docker-compose.yml
```

Happy Learning! 🚀
