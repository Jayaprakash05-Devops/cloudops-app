"""
ChatOps Bot Service - Chat-based operations interface
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime
import uvicorn
import random

app = FastAPI(title="ChatOps Bot", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

COMMANDS = [
    {"command": "/status", "description": "Get system status"},
    {"command": "/cost", "description": "View cloud costs"},
    {"command": "/k8s pods", "description": "List Kubernetes pods"},
    {"command": "/k8s scale", "description": "Scale a deployment"},
    {"command": "/incident create", "description": "Create an incident"},
    {"command": "/incident list", "description": "List open incidents"},
    {"command": "/deploy", "description": "Trigger a deployment"},
    {"command": "/approve", "description": "Approve pending deployment"},
    {"command": "/oncall", "description": "Check who's on-call"},
    {"command": "/help", "description": "Show available commands"}
]

class Command(BaseModel):
    command_id: str
    command: str
    user: str
    channel: str
    timestamp: str
    response: Optional[str]
    status: str

class Notification(BaseModel):
    notification_id: str
    type: str
    title: str
    message: str
    severity: str
    channels: List[str]
    sent_at: str

def process_command(cmd: str, user: str) -> str:
    """Process chatops command and return response"""
    cmd = cmd.strip().lower()

    if cmd.startswith("/status"):
        return f"🟢 All systems operational\n• API: Healthy\n• Database: Healthy\n• Cache: Healthy\n• Deployments: 3 in progress"

    elif cmd.startswith("/cost"):
        return f"💰 Cloud Costs Today\n• AWS: $456.78\n• GCP: $234.12\n• Azure: $189.45\n• Total: $880.35\n• Budget: $1000/day (88% used)"

    elif cmd.startswith("/k8s pods"):
        return f"☸️ Kubernetes Pods\n• Running: 47\n• Pending: 2\n• Failed: 0\n• Total: 49"

    elif cmd.startswith("/k8s scale"):
        return f"⚙️ Scaling deployment...\n• Deployment: frontend\n• Old replicas: 3\n• New replicas: 5\n• Status: In progress"

    elif cmd.startswith("/incident create"):
        inc_id = f"INC-{random.randint(1000, 9999)}"
        return f"🚨 Incident Created\n• ID: {inc_id}\n• Status: Investigating\n• Assigned: On-call engineer\n• Created by: {user}"

    elif cmd.startswith("/incident list"):
        return f"📋 Open Incidents\n• INC-5678: API latency spike (High)\n• INC-5679: Database connection pool (Medium)\n• INC-5680: Cache miss rate elevated (Low)"

    elif cmd.startswith("/deploy"):
        return f"🚀 Deployment Triggered\n• Application: backend-api\n• Environment: staging\n• Strategy: rolling\n• Status: Running\n• Pipeline: https://github.com/..."

    elif cmd.startswith("/approve"):
        return f"✅ Deployment Approved\n• Deployment: backend-api v1.23.4\n• Environment: production\n• Approved by: {user}\n• Starting deployment..."

    elif cmd.startswith("/oncall"):
        return f"👤 On-Call Schedule\n• Backend: Alice Johnson\n• Frontend: Bob Smith\n• Infrastructure: Charlie Brown\n• Shift ends: 6h 23m"

    elif cmd.startswith("/help"):
        help_text = "📚 Available Commands\n\n"
        for cmd_info in COMMANDS:
            help_text += f"• {cmd_info['command']}: {cmd_info['description']}\n"
        return help_text

    else:
        return f"❓ Unknown command: {cmd}\n\nType /help to see available commands"

def generate_mock_history():
    """Generate mock command history"""
    history = []
    cmds = ["/status", "/cost", "/k8s pods", "/incident list", "/deploy", "/oncall"]
    users = ["alice", "bob", "charlie"]

    for i in range(10):
        cmd = random.choice(cmds)
        user = random.choice(users)
        history.append({
            "command_id": f"CMD-{1000 + i}",
            "command": cmd,
            "user": user,
            "channel": "ops-channel",
            "timestamp": (datetime.utcnow()).isoformat(),
            "response": process_command(cmd, user),
            "status": "completed"
        })

    return history

@app.get("/")
async def root():
    return {
        "service": "ChatOps Bot",
        "version": "1.0.0",
        "status": "running",
        "features": ["slash-commands", "notifications", "interactive-workflows", "natural-language"]
    }

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/commands")
async def get_commands():
    """Get available slash commands"""
    return {"commands": COMMANDS}

@app.post("/commands/execute")
async def execute_command(command: str, user: str, channel: str = "general"):
    """Execute a slash command"""
    command_id = f"CMD-{random.randint(1000, 9999)}"
    response = process_command(command, user)

    return {
        "command_id": command_id,
        "command": command,
        "user": user,
        "channel": channel,
        "timestamp": datetime.utcnow().isoformat(),
        "response": response,
        "status": "completed"
    }

@app.get("/commands/history", response_model=List[Command])
async def get_command_history(user: Optional[str] = None, limit: int = 50):
    """Get command execution history"""
    history = generate_mock_history()

    if user:
        history = [h for h in history if h["user"] == user]

    return history[:min(limit, 50)]

@app.post("/notifications/send")
async def send_notification(
    title: str,
    message: str,
    severity: str = "info",
    channels: List[str] = ["general"]
):
    """Send a notification to chat channels"""
    notification_id = f"NOTIF-{random.randint(1000, 9999)}"

    severity_emoji = {
        "critical": "🔴",
        "high": "🟠",
        "medium": "🟡",
        "low": "🟢",
        "info": "ℹ️"
    }

    formatted_message = f"{severity_emoji.get(severity, 'ℹ️')} **{title}**\n{message}"

    return {
        "notification_id": notification_id,
        "type": "notification",
        "title": title,
        "message": formatted_message,
        "severity": severity,
        "channels": channels,
        "sent_at": datetime.utcnow().isoformat(),
        "status": "sent"
    }

@app.get("/notifications/recent", response_model=List[Notification])
async def get_recent_notifications(limit: int = 20):
    """Get recent notifications"""
    notifications = [
        {
            "notification_id": f"NOTIF-{1000 + i}",
            "type": "alert" if i % 3 == 0 else "notification",
            "title": random.choice([
                "Deployment completed",
                "Incident resolved",
                "High CPU usage detected",
                "Cost budget warning",
                "New pods created"
            ]),
            "message": "System notification message",
            "severity": random.choice(["info", "low", "medium", "high"]),
            "channels": ["ops-channel"],
            "sent_at": datetime.utcnow().isoformat()
        }
        for i in range(limit)
    ]

    return notifications[:min(limit, 20)]

@app.get("/integrations")
async def get_integrations():
    """Get configured chat integrations"""
    return {
        "integrations": [
            {
                "platform": "Discord",
                "status": "connected",
                "bot_name": "CloudOps Bot",
                "channels": 5,
                "commands_today": 24
            },
            {
                "platform": "Slack",
                "status": "ready",
                "bot_name": "CloudOps",
                "channels": 0,
                "commands_today": 0
            },
            {
                "platform": "Microsoft Teams",
                "status": "not_configured",
                "bot_name": None,
                "channels": 0,
                "commands_today": 0
            }
        ]
    }

@app.post("/workflows/interactive")
async def create_interactive_workflow(workflow_type: str, user: str):
    """Create an interactive workflow"""
    workflows = {
        "deploy": {
            "steps": [
                {"step": 1, "prompt": "Select environment", "options": ["staging", "production"]},
                {"step": 2, "prompt": "Select deployment strategy", "options": ["rolling", "blue-green", "canary"]},
                {"step": 3, "prompt": "Confirm deployment", "options": ["yes", "no"]}
            ]
        },
        "incident": {
            "steps": [
                {"step": 1, "prompt": "Select severity", "options": ["critical", "high", "medium", "low"]},
                {"step": 2, "prompt": "Describe the issue", "type": "text"},
                {"step": 3, "prompt": "Assign to", "options": ["oncall", "specific_user"]}
            ]
        }
    }

    workflow = workflows.get(workflow_type, {"steps": []})

    return {
        "workflow_id": f"WF-{random.randint(1000, 9999)}",
        "workflow_type": workflow_type,
        "user": user,
        "status": "in_progress",
        "current_step": 1,
        "steps": workflow["steps"]
    }

@app.get("/stats")
async def get_bot_stats():
    """Get bot usage statistics"""
    return {
        "total_commands": 1247,
        "today": 42,
        "active_users": 8,
        "top_commands": [
            {"/status": 312},
            {"/cost": 245},
            {"/k8s pods": 198},
            {"/incident list": 176},
            {"/deploy": 145}
        ],
        "notifications_sent": 89,
        "response_time_ms": 145,
        "success_rate": 99.2
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8005)
