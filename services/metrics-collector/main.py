"""
Metrics Collector Service - Cross-service metrics aggregation and analytics
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime, timedelta
import uvicorn
import random

app = FastAPI(title="Metrics Collector", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SERVICES = ["cost-optimizer", "k8s-manager", "incident-manager", "automation-service", "chatops-bot"]
METRIC_TYPES = ["response_time", "error_rate", "request_count", "cpu_usage", "memory_usage"]

class Metric(BaseModel):
    metric_id: str
    service: str
    metric_type: str
    value: float
    unit: str
    timestamp: str
    tags: Dict[str, str]

class Dashboard(BaseModel):
    dashboard_id: str
    name: str
    description: str
    widgets: List[Dict]
    created_at: str

def generate_time_series(hours: int, base_value: float, variance: float):
    """Generate mock time series data"""
    data = []
    for i in range(hours):
        timestamp = datetime.utcnow() - timedelta(hours=hours-i)
        value = base_value + random.uniform(-variance, variance)
        data.append({
            "timestamp": timestamp.isoformat(),
            "value": round(value, 2)
        })
    return data

def generate_mock_metrics():
    """Generate mock metrics"""
    metrics = []
    for service in SERVICES:
        for metric_type in ["response_time", "request_count", "error_rate"]:
            value = random.uniform(10, 500) if metric_type == "response_time" else random.uniform(0, 100)
            unit = "ms" if metric_type == "response_time" else "count" if metric_type == "request_count" else "percent"

            metrics.append({
                "metric_id": f"M-{service}-{metric_type}-{random.randint(1000, 9999)}",
                "service": service,
                "metric_type": metric_type,
                "value": round(value, 2),
                "unit": unit,
                "timestamp": datetime.utcnow().isoformat(),
                "tags": {"environment": "production", "region": "us-east-1"}
            })
    return metrics

@app.get("/")
async def root():
    return {
        "service": "Metrics Collector",
        "version": "1.0.0",
        "status": "running",
        "features": ["metrics-collection", "aggregation", "time-series", "dashboards", "analytics"]
    }

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/metrics/current", response_model=List[Metric])
async def get_current_metrics(service: Optional[str] = None):
    """Get current metrics"""
    metrics = generate_mock_metrics()

    if service:
        metrics = [m for m in metrics if m["service"] == service]

    return metrics

@app.get("/metrics/{service}/{metric_type}")
async def get_service_metric(service: str, metric_type: str, hours: int = 24):
    """Get time-series metrics for a specific service"""
    if service not in SERVICES:
        raise HTTPException(status_code=404, detail="Service not found")

    base_value = 150 if metric_type == "response_time" else 1000
    variance = 50 if metric_type == "response_time" else 200

    data = generate_time_series(hours, base_value, variance)

    return {
        "service": service,
        "metric_type": metric_type,
        "unit": "ms" if metric_type == "response_time" else "count",
        "period_hours": hours,
        "data_points": data
    }

@app.get("/metrics/summary")
async def get_metrics_summary():
    """Get overall metrics summary"""
    return {
        "services": {
            service: {
                "status": "healthy",
                "response_time_ms": round(random.uniform(80, 200), 2),
                "request_count": random.randint(1000, 5000),
                "error_rate": round(random.uniform(0.1, 2.5), 2),
                "uptime_percent": round(random.uniform(99.5, 99.99), 2)
            }
            for service in SERVICES
        },
        "platform_health": "healthy",
        "total_requests_today": 45234,
        "avg_response_time_ms": 145,
        "total_errors_today": 89,
        "last_updated": datetime.utcnow().isoformat()
    }

@app.get("/metrics/compare")
async def compare_services(metric_type: str = "response_time", hours: int = 24):
    """Compare metrics across services"""
    comparisons = {}

    for service in SERVICES:
        base_value = random.uniform(100, 300)
        variance = 30
        data = generate_time_series(hours, base_value, variance)

        comparisons[service] = {
            "average": round(sum(d["value"] for d in data) / len(data), 2),
            "min": round(min(d["value"] for d in data), 2),
            "max": round(max(d["value"] for d in data), 2),
            "data": data
        }

    return {
        "metric_type": metric_type,
        "period_hours": hours,
        "comparisons": comparisons
    }

@app.post("/metrics/record")
async def record_metric(
    service: str,
    metric_type: str,
    value: float,
    tags: Optional[Dict[str, str]] = None
):
    """Record a new metric data point"""
    metric_id = f"M-{service}-{metric_type}-{random.randint(10000, 99999)}"

    return {
        "metric_id": metric_id,
        "service": service,
        "metric_type": metric_type,
        "value": value,
        "tags": tags or {},
        "timestamp": datetime.utcnow().isoformat(),
        "status": "recorded"
    }

@app.get("/dashboards", response_model=List[Dashboard])
async def get_dashboards():
    """Get available dashboards"""
    dashboards = [
        {
            "dashboard_id": "DASH-001",
            "name": "Platform Overview",
            "description": "High-level view of all services",
            "widgets": [
                {"type": "gauge", "metric": "uptime", "title": "Platform Uptime"},
                {"type": "line", "metric": "response_time", "title": "Response Time"},
                {"type": "bar", "metric": "request_count", "title": "Requests"}
            ],
            "created_at": "2026-01-15T10:00:00"
        },
        {
            "dashboard_id": "DASH-002",
            "name": "Cost Analytics",
            "description": "Cloud cost metrics and trends",
            "widgets": [
                {"type": "line", "metric": "daily_cost", "title": "Daily Spend"},
                {"type": "pie", "metric": "cost_by_provider", "title": "By Provider"},
                {"type": "gauge", "metric": "budget_usage", "title": "Budget Usage"}
            ],
            "created_at": "2026-02-01T10:00:00"
        },
        {
            "dashboard_id": "DASH-003",
            "name": "Kubernetes Health",
            "description": "K8s cluster metrics",
            "widgets": [
                {"type": "gauge", "metric": "pod_health", "title": "Pod Health"},
                {"type": "line", "metric": "cpu_usage", "title": "CPU Usage"},
                {"type": "line", "metric": "memory_usage", "title": "Memory Usage"}
            ],
            "created_at": "2026-02-10T10:00:00"
        }
    ]
    return dashboards

@app.get("/dashboards/{dashboard_id}")
async def get_dashboard(dashboard_id: str):
    """Get specific dashboard with live data"""
    dashboards = await get_dashboards()
    dashboard = next((d for d in dashboards if d["dashboard_id"] == dashboard_id), None)

    if not dashboard:
        raise HTTPException(status_code=404, detail="Dashboard not found")

    # Add live data to widgets
    for widget in dashboard["widgets"]:
        if widget["type"] == "line":
            widget["data"] = generate_time_series(24, random.uniform(100, 500), 50)
        elif widget["type"] == "gauge":
            widget["value"] = round(random.uniform(80, 99), 2)
            widget["max"] = 100
        elif widget["type"] == "bar":
            widget["data"] = {service: random.randint(100, 1000) for service in SERVICES}
        elif widget["type"] == "pie":
            widget["data"] = [
                {"label": "AWS", "value": random.randint(1000, 5000)},
                {"label": "GCP", "value": random.randint(1000, 3000)},
                {"label": "Azure", "value": random.randint(500, 2000)}
            ]

    return dashboard

@app.get("/analytics/trends")
async def get_trends(days: int = 7):
    """Get trend analytics"""
    return {
        "period_days": days,
        "trends": {
            "response_time": {
                "trend": "improving",
                "change_percent": -5.2,
                "current_avg": 142,
                "previous_avg": 150
            },
            "request_volume": {
                "trend": "increasing",
                "change_percent": 12.5,
                "current_avg": 45000,
                "previous_avg": 40000
            },
            "error_rate": {
                "trend": "stable",
                "change_percent": 0.3,
                "current_avg": 1.2,
                "previous_avg": 1.19
            },
            "cost": {
                "trend": "increasing",
                "change_percent": 3.8,
                "current_avg": 18500,
                "previous_avg": 17800
            }
        }
    }

@app.get("/analytics/correlations")
async def get_correlations():
    """Get metric correlations"""
    return {
        "correlations": [
            {
                "metric1": "deployment_frequency",
                "metric2": "incident_rate",
                "correlation": -0.65,
                "insight": "More frequent deployments correlate with fewer incidents"
            },
            {
                "metric1": "response_time",
                "metric2": "error_rate",
                "correlation": 0.72,
                "insight": "Higher response times correlate with higher error rates"
            },
            {
                "metric1": "cost",
                "metric2": "request_volume",
                "correlation": 0.89,
                "insight": "Cost increases linearly with request volume"
            }
        ]
    }

@app.get("/analytics/alerts")
async def get_metric_alerts():
    """Get metric-based alerts"""
    return {
        "active_alerts": [
            {
                "alert_id": "ALT-001",
                "metric": "response_time",
                "service": "k8s-manager",
                "threshold": 200,
                "current_value": 245,
                "severity": "warning",
                "triggered_at": (datetime.utcnow() - timedelta(minutes=15)).isoformat()
            },
            {
                "alert_id": "ALT-002",
                "metric": "error_rate",
                "service": "automation-service",
                "threshold": 2.0,
                "current_value": 2.8,
                "severity": "high",
                "triggered_at": (datetime.utcnow() - timedelta(minutes=5)).isoformat()
            }
        ]
    }

@app.post("/analytics/query")
async def custom_query(
    services: List[str],
    metrics: List[str],
    start_time: str,
    end_time: str
):
    """Execute custom analytics query"""
    return {
        "query_id": f"QRY-{random.randint(1000, 9999)}",
        "services": services,
        "metrics": metrics,
        "time_range": {"start": start_time, "end": end_time},
        "results": [
            {
                "service": svc,
                "metric": met,
                "data_points": random.randint(100, 1000)
            }
            for svc in services
            for met in metrics
        ],
        "execution_time_ms": random.randint(50, 200)
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8006)
