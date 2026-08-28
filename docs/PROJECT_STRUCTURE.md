# Project Structure

```
Synapse/
├── README.md                 # Project overview and main documentation
├── QUICKSTART.md            # Quick start guide (5-minute setup)
├── LEARNING_GUIDE.md        # In-depth learning guide for DevOps/SRE concepts
├── ARCHITECTURE.md          # Detailed architecture documentation
├── .gitignore              # Git ignore rules
│
├── docker-compose.yml      # Multi-container orchestration
│
├── docker/                 # Docker configuration
│   ├── Dockerfile.python   # Python services Dockerfile
│   └── Dockerfile.frontend # React frontend Dockerfile
│
├── services/               # Backend microservices (Python)
│   │
│   ├── service-registry/   # Port 8001 - Service discovery
│   │   ├── main.py         # FastAPI application
│   │   └── requirements.txt
│   │
│   ├── health-checker/     # Port 8002 - Health monitoring
│   │   ├── main.py         # FastAPI application
│   │   └── requirements.txt
│   │
│   ├── metrics-collector/  # Port 8003 - Metrics aggregation
│   │   ├── main.py         # FastAPI application
│   │   └── requirements.txt
│   │
│   └── alert-manager/      # Port 8004 - Alert management
│       ├── main.py         # FastAPI application
│       └── requirements.txt
│
├── frontend/               # React dashboard (Port 3000)
│   ├── package.json        # Node.js dependencies
│   ├── public/
│   │   └── index.html      # HTML template
│   └── src/
│       ├── index.js        # React entry point
│       ├── index.css       # Global styles
│       ├── App.js          # Main app component
│       ├── App.css         # App styles
│       └── components/     # React components
│           ├── Dashboard.js    # System overview
│           ├── Services.js     # Service management
│           ├── Metrics.js      # Metrics visualization
│           └── Alerts.js       # Alert configuration
│
└── scripts/                # Utility scripts
    ├── setup.sh            # Docker Compose setup
    ├── dev-setup.sh        # Local development setup
    └── test-services.sh    # API testing script
```

## File Purposes

### Documentation
- **README.md**: Project overview, tech stack, quick links
- **QUICKSTART.md**: Get started in 5 minutes
- **LEARNING_GUIDE.md**: Learn DevOps/SRE concepts through hands-on exercises
- **ARCHITECTURE.md**: System design, data flow, API specs

### Configuration
- **docker-compose.yml**: Define all services, networks, volumes
- **docker/Dockerfile.python**: Base image for Python services
- **docker/Dockerfile.frontend**: Base image for React app
- **.gitignore**: Exclude generated files from Git

### Backend Services (Python + FastAPI)
Each service follows the same structure:
- **main.py**: FastAPI application with async endpoints
- **requirements.txt**: Python dependencies

Service responsibilities:
1. **service-registry**: Service discovery, registration, catalog
2. **health-checker**: Periodic health checks, status tracking
3. **metrics-collector**: Time-series data, statistics, aggregation
4. **alert-manager**: Rule engine, alert evaluation, notifications

### Frontend (React)
- **package.json**: Dependencies and scripts
- **public/index.html**: HTML shell
- **src/index.js**: ReactDOM render
- **src/App.js**: Router and navigation
- **src/components/**: Page components (Dashboard, Services, Metrics, Alerts)

### Scripts
- **setup.sh**: One-command Docker Compose setup
- **dev-setup.sh**: Setup Python venvs and Node.js for local development
- **test-services.sh**: Test API endpoints and workflows

## Service Ports

| Service            | Port | Technology |
|-------------------|------|------------|
| Service Registry  | 8001 | Python/FastAPI |
| Health Checker    | 8002 | Python/FastAPI |
| Metrics Collector | 8003 | Python/FastAPI |
| Alert Manager     | 8004 | Python/FastAPI |
| Frontend          | 3000 | React |
| Redis             | 6379 | Redis |

## Data Storage (Redis)

```
Redis Keys Structure:

services                              # Hash: Service catalog
  → {service_id}: {service_json}

health_checks:{service_id}           # List: Health check history
  → [{check_result}...]

metrics:{service_id}:{metric_type}   # List: Time-series metrics
  → [{metric_point}...]

alert_rules                          # Hash: Alert rule definitions
  → {rule_id}: {rule_json}

alerts:{service_id}                  # List: Alert history
  → [{alert}...]

notification_channels                # Hash: Notification configs
  → {channel_id}: {channel_json}

Pub/Sub Channels:
  - health_updates                   # Real-time health status
  - alert_fired                      # Alert triggered
  - alert_resolved                   # Alert resolved
```

## Adding a New Service

1. Create directory: `services/my-service/`
2. Create `main.py`:
   ```python
   from fastapi import FastAPI
   import uvicorn

   app = FastAPI(title="My Service")

   @app.get("/health")
   async def health():
       return {"status": "healthy"}

   if __name__ == "__main__":
       uvicorn.run(app, host="0.0.0.0", port=8005)
   ```
3. Create `requirements.txt`:
   ```
   fastapi==0.104.1
   uvicorn[standard]==0.24.0
   ```
4. Add to `docker-compose.yml`:
   ```yaml
   my-service:
     build:
       context: ./services/my-service
       dockerfile: ../../docker/Dockerfile.python
     ports:
       - "8005:8005"
     depends_on:
       - redis
   ```

## Technology Stack Summary

### Backend
- **Language**: Python 3.11+
- **Framework**: FastAPI (async web framework)
- **Validation**: Pydantic
- **HTTP Client**: httpx (async)
- **Data Store**: Redis

### Frontend
- **Language**: JavaScript (ES6+)
- **Framework**: React 18
- **Routing**: React Router
- **HTTP Client**: Axios
- **Charts**: Recharts

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Data Store**: Redis 7

### DevOps
- **Service Discovery**: Custom (Service Registry)
- **Health Checks**: HTTP-based
- **Metrics**: Custom collector
- **Alerts**: Rule-based engine
- **Logging**: stdout/stderr (collected by Docker)

## Code Statistics

| Category | Files | Lines of Code (approx) |
|----------|-------|----------------------|
| Backend Python | 4 | ~1,200 |
| Frontend React | 8 | ~1,500 |
| Configuration | 5 | ~200 |
| Documentation | 4 | ~2,000 |
| **Total** | **21** | **~4,900** |

## Next Steps for Learning

1. **Understand the Code**
   - Read `services/service-registry/main.py` first
   - Follow the data flow from registration to monitoring

2. **Run the Platform**
   - Use Docker Compose: `./scripts/setup.sh`
   - Register services and watch them being monitored

3. **Extend It**
   - Add authentication
   - Add more metric types
   - Add Slack notifications
   - Add a PostgreSQL database
   - Deploy to Kubernetes

4. **Deep Dive**
   - Read LEARNING_GUIDE.md for concepts
   - Read ARCHITECTURE.md for design decisions
   - Try the hands-on exercises

Happy Learning! 🚀
