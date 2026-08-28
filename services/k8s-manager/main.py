"""
Kubernetes Manager Service - K8s cluster and resource management
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime
import uvicorn
import random

app = FastAPI(title="Kubernetes Manager", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

NAMESPACES = ["default", "production", "staging", "development"]
POD_STATUSES = ["Running", "Pending", "Failed", "Succeeded"]
NODE_STATUSES = ["Ready", "NotReady", "SchedulingDisabled"]

class Cluster(BaseModel):
    cluster_id: str
    name: str
    version: str
    nodes: int
    pods: int
    status: str
    region: str
    provider: str

class Pod(BaseModel):
    name: str
    namespace: str
    status: str
    node: str
    cpu_usage: str
    memory_usage: str
    restarts: int
    age: str

class Deployment(BaseModel):
    name: str
    namespace: str
    replicas: int
    available: int
    ready: int
    up_to_date: int
    age: str

class Node(BaseModel):
    name: str
    status: str
    roles: List[str]
    cpu_capacity: str
    memory_capacity: str
    cpu_usage: str
    memory_usage: str
    pods: int

def generate_mock_clusters():
    clusters = []
    for i in range(3):
        clusters.append({
            "cluster_id": f"cluster-{i+1}",
            "name": f"{['production', 'staging', 'development'][i]}-cluster",
            "version": f"1.{random.randint(25, 28)}.{random.randint(0, 5)}",
            "nodes": random.randint(3, 10),
            "pods": random.randint(20, 100),
            "status": random.choice(["Healthy", "Healthy", "Warning"]),
            "region": random.choice(["us-east-1", "us-west-2", "eu-west-1"]),
            "provider": random.choice(["AWS EKS", "GCP GKE", "Azure AKS"])
        })
    return clusters

def generate_mock_pods(namespace="default", count=10):
    pods = []
    for i in range(count):
        pods.append({
            "name": f"app-{random.choice(['web', 'api', 'worker', 'cache'])}-{random.randint(1000, 9999)}",
            "namespace": namespace,
            "status": random.choice(["Running", "Running", "Running", "Pending"]),
            "node": f"node-{random.randint(1, 5)}",
            "cpu_usage": f"{random.randint(10, 500)}m",
            "memory_usage": f"{random.randint(100, 2000)}Mi",
            "restarts": random.randint(0, 5),
            "age": f"{random.randint(1, 30)}d"
        })
    return pods

def generate_mock_deployments(namespace="default"):
    deployments = []
    apps = ["frontend", "backend", "api", "worker", "redis", "postgres"]
    for app in apps:
        replicas = random.randint(2, 10)
        available = replicas if random.random() > 0.2 else replicas - 1
        deployments.append({
            "name": f"{app}-deployment",
            "namespace": namespace,
            "replicas": replicas,
            "available": available,
            "ready": available,
            "up_to_date": available,
            "age": f"{random.randint(5, 90)}d"
        })
    return deployments

def generate_mock_nodes():
    nodes = []
    for i in range(5):
        cpu_capacity = random.choice(["4", "8", "16"])
        memory_capacity = random.choice(["16Gi", "32Gi", "64Gi"])
        nodes.append({
            "name": f"node-{i+1}",
            "status": random.choice(["Ready", "Ready", "Ready", "NotReady"]),
            "roles": ["worker"] if i > 0 else ["control-plane", "master"],
            "cpu_capacity": cpu_capacity,
            "memory_capacity": memory_capacity,
            "cpu_usage": f"{random.randint(10, 80)}%",
            "memory_usage": f"{random.randint(20, 70)}%",
            "pods": random.randint(5, 30)
        })
    return nodes

@app.get("/")
async def root():
    return {
        "service": "Kubernetes Manager",
        "version": "1.0.0",
        "status": "running",
        "features": ["cluster-management", "pod-operations", "deployments", "scaling", "monitoring"]
    }

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/clusters", response_model=List[Cluster])
async def get_clusters():
    """Get all K8s clusters"""
    return generate_mock_clusters()

@app.get("/clusters/{cluster_id}")
async def get_cluster(cluster_id: str):
    """Get specific cluster details"""
    clusters = generate_mock_clusters()
    cluster = next((c for c in clusters if c["cluster_id"] == cluster_id), None)
    if not cluster:
        raise HTTPException(status_code=404, detail="Cluster not found")
    return cluster

@app.get("/clusters/{cluster_id}/health")
async def get_cluster_health(cluster_id: str):
    """Get cluster health metrics"""
    return {
        "cluster_id": cluster_id,
        "health_status": random.choice(["Healthy", "Degraded", "Critical"]),
        "metrics": {
            "cpu_usage": f"{random.randint(30, 80)}%",
            "memory_usage": f"{random.randint(40, 75)}%",
            "disk_usage": f"{random.randint(20, 60)}%",
            "pod_count": random.randint(50, 200),
            "node_count": random.randint(3, 10)
        },
        "issues": [
            {"type": "warning", "message": "Node node-3 has high memory usage"},
            {"type": "info", "message": "2 pods are pending scheduling"}
        ] if random.random() > 0.5 else [],
        "last_checked": datetime.utcnow().isoformat()
    }

@app.get("/namespaces")
async def get_namespaces():
    """Get all namespaces"""
    return {
        "namespaces": [
            {"name": ns, "status": "Active", "pods": random.randint(10, 50)}
            for ns in NAMESPACES
        ]
    }

@app.get("/pods", response_model=List[Pod])
async def get_pods(namespace: str = "default", limit: int = 50):
    """Get pods in namespace"""
    return generate_mock_pods(namespace, min(limit, 50))

@app.get("/pods/{namespace}/{pod_name}")
async def get_pod(namespace: str, pod_name: str):
    """Get specific pod details"""
    pods = generate_mock_pods(namespace)
    pod = pods[0] if pods else None
    if not pod:
        raise HTTPException(status_code=404, detail="Pod not found")
    return {
        **pod,
        "labels": {"app": "web", "version": "v1", "env": namespace},
        "containers": [
            {"name": "main", "image": "app:latest", "status": "Running"}
        ],
        "events": [
            {"type": "Normal", "reason": "Started", "message": "Container started", "time": "2m ago"},
            {"type": "Normal", "reason": "Pulled", "message": "Container image pulled", "time": "3m ago"}
        ]
    }

@app.get("/pods/{namespace}/{pod_name}/logs")
async def get_pod_logs(namespace: str, pod_name: str, lines: int = 100):
    """Get pod logs"""
    log_lines = [
        f"[{datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')}] INFO: Application started",
        "[2026-08-27 10:00:01] INFO: Connected to database",
        "[2026-08-27 10:00:02] INFO: Listening on port 8080",
        "[2026-08-27 10:00:15] INFO: Request received: GET /api/users",
        "[2026-08-27 10:00:16] INFO: Query executed in 45ms",
        "[2026-08-27 10:00:20] WARNING: High memory usage detected",
        "[2026-08-27 10:00:30] INFO: Health check passed"
    ]
    return {"logs": log_lines[:min(lines, 100)]}

@app.get("/deployments", response_model=List[Deployment])
async def get_deployments(namespace: str = "default"):
    """Get deployments in namespace"""
    return generate_mock_deployments(namespace)

@app.post("/deployments/{namespace}/{deployment_name}/scale")
async def scale_deployment(namespace: str, deployment_name: str, replicas: int):
    """Scale a deployment"""
    if replicas < 0 or replicas > 100:
        raise HTTPException(status_code=400, detail="Replicas must be between 0 and 100")
    return {
        "message": f"Scaled {deployment_name} to {replicas} replicas",
        "namespace": namespace,
        "deployment": deployment_name,
        "replicas": replicas,
        "status": "scaling"
    }

@app.post("/deployments/{namespace}/{deployment_name}/restart")
async def restart_deployment(namespace: str, deployment_name: str):
    """Restart a deployment"""
    return {
        "message": f"Restarting {deployment_name}",
        "namespace": namespace,
        "deployment": deployment_name,
        "status": "restarting"
    }

@app.get("/nodes", response_model=List[Node])
async def get_nodes():
    """Get cluster nodes"""
    return generate_mock_nodes()

@app.get("/nodes/{node_name}")
async def get_node(node_name: str):
    """Get specific node details"""
    nodes = generate_mock_nodes()
    node = next((n for n in nodes if n["name"] == node_name), None)
    if not node:
        raise HTTPException(status_code=404, detail="Node not found")
    return {
        **node,
        "conditions": [
            {"type": "Ready", "status": "True", "reason": "KubeletReady"},
            {"type": "MemoryPressure", "status": "False", "reason": "KubeletHasSufficientMemory"},
            {"type": "DiskPressure", "status": "False", "reason": "KubeletHasNoDiskPressure"}
        ],
        "allocatable": {
            "cpu": node["cpu_capacity"],
            "memory": node["memory_capacity"],
            "pods": "110"
        }
    }

@app.get("/recommendations")
async def get_recommendations():
    """Get optimization recommendations"""
    recs = [
        {
            "type": "scaling",
            "severity": "medium",
            "resource": "deployment/frontend",
            "issue": "High CPU usage detected (85%)",
            "recommendation": "Consider scaling from 3 to 5 replicas"
        },
        {
            "type": "resources",
            "severity": "low",
            "resource": "pod/worker-1234",
            "issue": "Requested resources exceed usage by 60%",
            "recommendation": "Reduce memory request from 2Gi to 800Mi"
        },
        {
            "type": "hpa",
            "severity": "high",
            "resource": "deployment/api",
            "issue": "No HorizontalPodAutoscaler configured",
            "recommendation": "Enable HPA with target CPU 70%, min 2, max 10"
        }
    ]
    return {"recommendations": recs}

@app.get("/events")
async def get_events(namespace: str = "all", limit: int = 50):
    """Get cluster events"""
    events = [
        {"type": "Normal", "reason": "ScalingReplicaSet", "message": "Scaled up replica set", "time": "2m ago"},
        {"type": "Warning", "reason": "FailedScheduling", "message": "Pod cannot be scheduled", "time": "5m ago"},
        {"type": "Normal", "reason": "Pulled", "message": "Container image pulled", "time": "10m ago"}
    ]
    return {"events": events[:min(limit, 50)], "namespace": namespace}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8002)
