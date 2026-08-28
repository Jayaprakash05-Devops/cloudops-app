"""
Cost Optimizer Service - Cloud cost analysis and optimization
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime, timedelta
import uvicorn
import random

app = FastAPI(title="Cost Optimizer", version="1.0.0")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mock data generators
CLOUD_PROVIDERS = ["AWS", "GCP", "Azure"]
RESOURCE_TYPES = {
    "AWS": ["EC2", "S3", "RDS", "Lambda", "EBS"],
    "GCP": ["Compute Engine", "Cloud Storage", "Cloud SQL", "Cloud Functions"],
    "Azure": ["Virtual Machines", "Blob Storage", "SQL Database", "Functions"]
}

class CostData(BaseModel):
    provider: str
    resource_type: str
    resource_name: str
    daily_cost: float
    monthly_cost: float
    region: str
    status: str  # active, idle, unused

class Recommendation(BaseModel):
    recommendation_id: str
    provider: str
    resource: str
    issue: str
    suggestion: str
    potential_savings: float
    priority: str  # high, medium, low

class BudgetAlert(BaseModel):
    alert_id: str
    budget_name: str
    threshold: float
    current_spend: float
    percentage: float
    status: str  # warning, critical

def generate_mock_costs():
    """Generate mock cloud cost data"""
    costs = []
    for provider in CLOUD_PROVIDERS:
        for resource_type in RESOURCE_TYPES[provider]:
            for i in range(random.randint(2, 5)):
                daily = round(random.uniform(10, 500), 2)
                costs.append({
                    "provider": provider,
                    "resource_type": resource_type,
                    "resource_name": f"{resource_type.lower().replace(' ', '-')}-{i+1}",
                    "daily_cost": daily,
                    "monthly_cost": round(daily * 30, 2),
                    "region": random.choice(["us-east-1", "us-west-2", "eu-west-1"]),
                    "status": random.choice(["active", "active", "idle", "unused"])
                })
    return costs

def generate_recommendations(costs):
    """Generate cost optimization recommendations"""
    recs = []
    rec_id = 1
    for cost in costs:
        if cost["status"] == "unused":
            recs.append({
                "recommendation_id": f"REC-{rec_id:04d}",
                "provider": cost["provider"],
                "resource": cost["resource_name"],
                "issue": "Unused resource detected",
                "suggestion": f"Delete unused {cost['resource_type']} to save costs",
                "potential_savings": cost["monthly_cost"],
                "priority": "high"
            })
            rec_id += 1
        elif cost["status"] == "idle":
            savings = cost["monthly_cost"] * 0.6
            recs.append({
                "recommendation_id": f"REC-{rec_id:04d}",
                "provider": cost["provider"],
                "resource": cost["resource_name"],
                "issue": "Resource is idle (low utilization)",
                "suggestion": f"Right-size or schedule {cost['resource_type']} to save 60%",
                "potential_savings": round(savings, 2),
                "priority": "medium"
            })
            rec_id += 1
    return recs

@app.get("/")
async def root():
    return {
        "service": "Cost Optimizer",
        "version": "1.0.0",
        "status": "running",
        "features": ["cost-analysis", "recommendations", "budget-tracking", "forecasting"]
    }

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/costs/summary")
async def get_cost_summary():
    """Get overall cost summary"""
    costs = generate_mock_costs()

    total_daily = sum(c["daily_cost"] for c in costs)
    total_monthly = sum(c["monthly_cost"] for c in costs)

    by_provider = {}
    for provider in CLOUD_PROVIDERS:
        provider_costs = [c for c in costs if c["provider"] == provider]
        by_provider[provider] = {
            "daily": round(sum(c["daily_cost"] for c in provider_costs), 2),
            "monthly": round(sum(c["monthly_cost"] for c in provider_costs), 2),
            "resources": len(provider_costs)
        }

    return {
        "total_daily_cost": round(total_daily, 2),
        "total_monthly_cost": round(total_monthly, 2),
        "total_resources": len(costs),
        "by_provider": by_provider,
        "last_updated": datetime.utcnow().isoformat()
    }

@app.get("/costs/details", response_model=List[CostData])
async def get_cost_details():
    """Get detailed cost breakdown"""
    costs = generate_mock_costs()
    return costs

@app.get("/costs/trends")
async def get_cost_trends(days: int = 30):
    """Get cost trends over time"""
    trends = []
    base_cost = random.uniform(5000, 8000)

    for i in range(days):
        date = datetime.utcnow() - timedelta(days=days-i)
        daily_cost = base_cost + random.uniform(-500, 500)
        trends.append({
            "date": date.strftime("%Y-%m-%d"),
            "cost": round(daily_cost, 2),
            "aws": round(daily_cost * 0.45, 2),
            "gcp": round(daily_cost * 0.30, 2),
            "azure": round(daily_cost * 0.25, 2)
        })

    return {"trends": trends, "period_days": days}

@app.get("/recommendations", response_model=List[Recommendation])
async def get_recommendations():
    """Get cost optimization recommendations"""
    costs = generate_mock_costs()
    recs = generate_recommendations(costs)
    return recs

@app.get("/recommendations/summary")
async def get_recommendations_summary():
    """Get summary of potential savings"""
    costs = generate_mock_costs()
    recs = generate_recommendations(costs)

    total_savings = sum(r["potential_savings"] for r in recs)

    by_priority = {
        "high": [r for r in recs if r["priority"] == "high"],
        "medium": [r for r in recs if r["priority"] == "medium"],
        "low": [r for r in recs if r["priority"] == "low"]
    }

    return {
        "total_recommendations": len(recs),
        "potential_monthly_savings": round(total_savings, 2),
        "potential_annual_savings": round(total_savings * 12, 2),
        "by_priority": {
            "high": {"count": len(by_priority["high"]), "savings": round(sum(r["potential_savings"] for r in by_priority["high"]), 2)},
            "medium": {"count": len(by_priority["medium"]), "savings": round(sum(r["potential_savings"] for r in by_priority["medium"]), 2)},
            "low": {"count": len(by_priority["low"]), "savings": round(sum(r["potential_savings"] for r in by_priority["low"]), 2)}
        }
    }

@app.get("/budget/alerts", response_model=List[BudgetAlert])
async def get_budget_alerts():
    """Get budget alerts"""
    alerts = []
    budgets = [
        {"name": "AWS Production", "threshold": 10000, "current": 11200},
        {"name": "GCP Development", "threshold": 3000, "current": 2850},
        {"name": "Azure Testing", "threshold": 2000, "current": 2400}
    ]

    for i, budget in enumerate(budgets):
        percentage = (budget["current"] / budget["threshold"]) * 100
        status = "critical" if percentage > 100 else "warning" if percentage > 80 else "ok"

        if status != "ok":
            alerts.append({
                "alert_id": f"ALERT-{i+1:03d}",
                "budget_name": budget["name"],
                "threshold": budget["threshold"],
                "current_spend": budget["current"],
                "percentage": round(percentage, 1),
                "status": status
            })

    return alerts

@app.get("/forecast")
async def get_forecast(days: int = 30):
    """Forecast future costs"""
    current_monthly = random.uniform(15000, 20000)
    growth_rate = random.uniform(0.02, 0.05)  # 2-5% monthly growth

    forecast = []
    for i in range(1, days + 1):
        date = datetime.utcnow() + timedelta(days=i)
        daily_forecast = (current_monthly / 30) * (1 + (growth_rate * i / 30))
        forecast.append({
            "date": date.strftime("%Y-%m-%d"),
            "forecasted_cost": round(daily_forecast, 2)
        })

    return {
        "forecast_period_days": days,
        "current_monthly_cost": round(current_monthly, 2),
        "forecasted_monthly_cost": round(current_monthly * (1 + growth_rate), 2),
        "daily_forecast": forecast
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)
