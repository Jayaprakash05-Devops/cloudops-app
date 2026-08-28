"""
Incident Manager Service - Incident tracking and response orchestration
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime, timedelta
import uvicorn
import random
import uuid

app = FastAPI(title="Incident Manager", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SEVERITIES = ["critical", "high", "medium", "low"]
STATUSES = ["investigating", "identified", "monitoring", "resolved"]
SERVICES = ["api-service", "database", "frontend", "cache", "payment-gateway"]

class Incident(BaseModel):
    incident_id: str
    title: str
    description: str
    severity: str
    status: str
    service: str
    created_at: str
    updated_at: str
    assigned_to: str
    estimated_impact: str

class OnCallSchedule(BaseModel):
    schedule_id: str
    team: str
    current_oncall: str
    backup: str
    shift_start: str
    shift_end: str

class PostMortem(BaseModel):
    incident_id: str
    title: str
    date: str
    duration: str
    impact: str
    root_cause: str
    resolution: str
    action_items: List[str]

def generate_mock_incidents():
    incidents = []
    titles = [
        "API response time degradation",
        "Database connection pool exhausted",
        "High error rate on payment service",
        "Memory leak detected in worker pods",
        "SSL certificate expiring soon",
        "Unusual spike in 5xx errors"
    ]

    for i in range(6):
        created = datetime.utcnow() - timedelta(hours=random.randint(1, 72))
        incidents.append({
            "incident_id": f"INC-{random.randint(1000, 9999)}",
            "title": titles[i],
            "description": f"Detected issue with {random.choice(SERVICES)}. Investigating root cause.",
            "severity": random.choice(SEVERITIES),
            "status": random.choice(STATUSES),
            "service": random.choice(SERVICES),
            "created_at": created.isoformat(),
            "updated_at": (created + timedelta(minutes=random.randint(5, 120))).isoformat(),
            "assigned_to": random.choice(["alice@example.com", "bob@example.com", "charlie@example.com"]),
            "estimated_impact": random.choice(["10% of users", "critical path", "non-critical", "all regions"])
        })
    return incidents

def generate_oncall_schedule():
    engineers = ["Alice Johnson", "Bob Smith", "Charlie Brown", "Diana Prince"]
    teams = ["Backend", "Frontend", "Infrastructure", "Database"]

    schedules = []
    for team in teams:
        shift_start = datetime.utcnow()
        shift_end = shift_start + timedelta(hours=24)

        schedules.append({
            "schedule_id": f"SCHED-{team.upper()}",
            "team": team,
            "current_oncall": random.choice(engineers),
            "backup": random.choice(engineers),
            "shift_start": shift_start.isoformat(),
            "shift_end": shift_end.isoformat()
        })
    return schedules

@app.get("/")
async def root():
    return {
        "service": "Incident Manager",
        "version": "1.0.0",
        "status": "running",
        "features": ["incident-tracking", "oncall-management", "sla-monitoring", "postmortems", "auto-remediation"]
    }

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/incidents", response_model=List[Incident])
async def get_incidents(status: Optional[str] = None, severity: Optional[str] = None):
    """Get all incidents with optional filters"""
    incidents = generate_mock_incidents()

    if status:
        incidents = [i for i in incidents if i["status"] == status]
    if severity:
        incidents = [i for i in incidents if i["severity"] == severity]

    return incidents

@app.get("/incidents/{incident_id}")
async def get_incident(incident_id: str):
    """Get specific incident details"""
    incidents = generate_mock_incidents()
    incident = next((i for i in incidents if i["incident_id"] == incident_id), None)

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    # Add timeline
    incident["timeline"] = [
        {"time": incident["created_at"], "event": "Incident created", "user": "System"},
        {"time": incident["updated_at"], "event": "Assigned to engineer", "user": incident["assigned_to"]},
        {"time": incident["updated_at"], "event": "Status updated", "user": incident["assigned_to"]}
    ]

    return incident

@app.post("/incidents")
async def create_incident(
    title: str,
    description: str,
    severity: str,
    service: str,
    assigned_to: Optional[str] = None
):
    """Create a new incident"""
    incident_id = f"INC-{random.randint(1000, 9999)}"
    now = datetime.utcnow().isoformat()

    return {
        "incident_id": incident_id,
        "title": title,
        "description": description,
        "severity": severity,
        "status": "investigating",
        "service": service,
        "created_at": now,
        "updated_at": now,
        "assigned_to": assigned_to or "unassigned",
        "estimated_impact": "TBD"
    }

@app.patch("/incidents/{incident_id}")
async def update_incident(
    incident_id: str,
    status: Optional[str] = None,
    assigned_to: Optional[str] = None
):
    """Update incident status or assignment"""
    return {
        "incident_id": incident_id,
        "updated_at": datetime.utcnow().isoformat(),
        "changes": {
            "status": status,
            "assigned_to": assigned_to
        }
    }

@app.get("/incidents/stats/summary")
async def get_incident_summary():
    """Get incident statistics"""
    incidents = generate_mock_incidents()

    by_severity = {}
    for sev in SEVERITIES:
        by_severity[sev] = len([i for i in incidents if i["severity"] == sev])

    by_status = {}
    for stat in STATUSES:
        by_status[stat] = len([i for i in incidents if i["status"] == stat])

    return {
        "total_incidents": len(incidents),
        "open_incidents": len([i for i in incidents if i["status"] != "resolved"]),
        "by_severity": by_severity,
        "by_status": by_status,
        "mttr_hours": round(random.uniform(0.5, 4.5), 2),
        "mttd_minutes": round(random.uniform(5, 45), 2)
    }

@app.get("/oncall", response_model=List[OnCallSchedule])
async def get_oncall_schedule():
    """Get current on-call schedule"""
    return generate_oncall_schedule()

@app.get("/oncall/{team}")
async def get_team_oncall(team: str):
    """Get on-call engineer for specific team"""
    schedules = generate_oncall_schedule()
    schedule = next((s for s in schedules if s["team"].lower() == team.lower()), None)

    if not schedule:
        raise HTTPException(status_code=404, detail="Team not found")

    return schedule

@app.post("/oncall/page")
async def page_oncall(team: str, message: str):
    """Page the on-call engineer"""
    schedules = generate_oncall_schedule()
    schedule = next((s for s in schedules if s["team"].lower() == team.lower()), None)

    if not schedule:
        raise HTTPException(status_code=404, detail="Team not found")

    return {
        "paged": schedule["current_oncall"],
        "team": team,
        "message": message,
        "time": datetime.utcnow().isoformat(),
        "status": "sent"
    }

@app.get("/postmortems", response_model=List[PostMortem])
async def get_postmortems():
    """Get post-mortem reports"""
    postmortems = [
        {
            "incident_id": "INC-1234",
            "title": "API Gateway Outage - March 2026",
            "date": "2026-03-15",
            "duration": "2h 15m",
            "impact": "15% of API requests failed",
            "root_cause": "Memory leak in connection pooling library",
            "resolution": "Updated library to v3.2.1 and implemented connection timeouts",
            "action_items": [
                "Add memory leak detection to CI/CD",
                "Implement connection pool monitoring",
                "Update runbook with mitigation steps"
            ]
        },
        {
            "incident_id": "INC-5678",
            "title": "Database Slowdown - February 2026",
            "date": "2026-02-20",
            "duration": "45m",
            "impact": "Query latency increased 10x",
            "root_cause": "Missing index on frequently queried table",
            "resolution": "Added compound index on user_id and created_at columns",
            "action_items": [
                "Review all high-traffic queries for index coverage",
                "Enable slow query logging",
                "Add query performance alerts"
            ]
        }
    ]
    return postmortems

@app.get("/sla/compliance")
async def get_sla_compliance():
    """Get SLA compliance metrics"""
    return {
        "current_month": {
            "uptime_percentage": round(random.uniform(99.5, 99.99), 2),
            "target": 99.9,
            "status": "on_track",
            "incidents": 3,
            "downtime_minutes": random.randint(10, 60)
        },
        "services": [
            {
                "service": "api-service",
                "uptime": 99.95,
                "target": 99.9,
                "status": "compliant"
            },
            {
                "service": "database",
                "uptime": 99.99,
                "target": 99.95,
                "status": "compliant"
            },
            {
                "service": "payment-gateway",
                "uptime": 99.85,
                "target": 99.9,
                "status": "at_risk"
            }
        ]
    }

@app.get("/runbooks")
async def get_runbooks():
    """Get available runbooks"""
    runbooks = [
        {"id": "RB-001", "title": "High CPU Usage Remediation", "service": "all"},
        {"id": "RB-002", "title": "Database Connection Pool Exhaustion", "service": "database"},
        {"id": "RB-003", "title": "Redis Cache Miss Storm", "service": "cache"},
        {"id": "RB-004", "title": "API Rate Limit Exceeded", "service": "api-service"}
    ]
    return {"runbooks": runbooks}

@app.post("/runbooks/{runbook_id}/execute")
async def execute_runbook(runbook_id: str, incident_id: str):
    """Execute automated remediation runbook"""
    return {
        "execution_id": str(uuid.uuid4()),
        "runbook_id": runbook_id,
        "incident_id": incident_id,
        "status": "executing",
        "started_at": datetime.utcnow().isoformat(),
        "steps": [
            {"step": 1, "action": "Identify affected pods", "status": "completed"},
            {"step": 2, "action": "Scale up replicas", "status": "in_progress"},
            {"step": 3, "action": "Monitor metrics", "status": "pending"}
        ]
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8003)
