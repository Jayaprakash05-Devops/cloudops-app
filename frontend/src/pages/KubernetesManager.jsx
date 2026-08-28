import React, { useState, useEffect } from 'react'
import api from '../services/api'

function KubernetesManager() {
  const [clusters, setClusters] = useState([])
  const [pods, setPods] = useState([])
  const [selectedCluster, setSelectedCluster] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const [clustersRes, podsRes] = await Promise.all([
        api.k8sManager.get('/clusters'),
        api.k8sManager.get('/pods?limit=10')
      ])
      setClusters(clustersRes.data)
      setPods(podsRes.data)
      setLoading(false)
    } catch (error) {
      console.error('Failed to load K8s data:', error)
      setLoading(false)
    }
  }

  const handleScale = async (deployment) => {
    const replicas = prompt('Enter new replica count:', '5')
    if (replicas) {
      try {
        await api.k8sManager.post(`/deployments/default/${deployment}/scale?replicas=${replicas}`)
        alert(`Scaled ${deployment} to ${replicas} replicas`)
      } catch (error) {
        alert('Failed to scale deployment')
      }
    }
  }

  if (loading) return <div className="loading">Loading Kubernetes data...</div>

  return (
    <div className="page-container">
      <div className="page-header">
        <h1 className="page-title"><span>☸️</span> Kubernetes Manager</h1>
        <p className="page-subtitle">Manage clusters, pods, and deployments</p>
      </div>

      <div className="stats-grid">
        <div className="stat-card" style={{ '--card-color': '#06b6d4', '--card-color-dark': '#0891b2' }}>
          <div className="stat-icon">🏗️</div>
          <div className="stat-label">Clusters</div>
          <div className="stat-value">{clusters.length}</div>
        </div>
        <div className="stat-card" style={{ '--card-color': '#10b981', '--card-color-dark': '#059669' }}>
          <div className="stat-icon">📦</div>
          <div className="stat-label">Running Pods</div>
          <div className="stat-value">{pods.filter(p => p.status === 'Running').length}</div>
        </div>
        <div className="stat-card" style={{ '--card-color': '#f59e0b', '--card-color-dark': '#d97706' }}>
          <div className="stat-icon">⏸️</div>
          <div className="stat-label">Pending Pods</div>
          <div className="stat-value">{pods.filter(p => p.status === 'Pending').length}</div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">🏗️ Kubernetes Clusters</h2>
          <button className="btn btn-primary" onClick={loadData}>Refresh</button>
        </div>
        <div className="card-content">
          <table className="table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Provider</th>
                <th>Version</th>
                <th>Nodes</th>
                <th>Pods</th>
                <th>Region</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {clusters.map(cluster => (
                <tr key={cluster.cluster_id}>
                  <td style={{ fontWeight: 600 }}>{cluster.name}</td>
                  <td>{cluster.provider}</td>
                  <td>{cluster.version}</td>
                  <td>{cluster.nodes}</td>
                  <td>{cluster.pods}</td>
                  <td>{cluster.region}</td>
                  <td>
                    <span className={`badge ${cluster.status === 'Healthy' ? 'badge-success' : 'badge-warning'}`}>
                      {cluster.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">📦 Pods</h2>
        </div>
        <div className="card-content">
          <table className="table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Namespace</th>
                <th>Node</th>
                <th>CPU</th>
                <th>Memory</th>
                <th>Restarts</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {pods.map((pod, idx) => (
                <tr key={idx}>
                  <td style={{ fontWeight: 600, fontFamily: 'monospace', fontSize: '0.85rem' }}>{pod.name}</td>
                  <td>{pod.namespace}</td>
                  <td>{pod.node}</td>
                  <td>{pod.cpu_usage}</td>
                  <td>{pod.memory_usage}</td>
                  <td>{pod.restarts}</td>
                  <td>
                    <span className={`badge ${pod.status === 'Running' ? 'badge-success' : 'badge-warning'}`}>
                      {pod.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">⚙️ Quick Actions</h2>
        </div>
        <div className="card-content">
          <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
            <button className="btn btn-primary" onClick={() => handleScale('frontend-deployment')}>
              Scale Frontend
            </button>
            <button className="btn btn-primary" onClick={() => handleScale('backend-deployment')}>
              Scale Backend
            </button>
            <button className="btn btn-secondary" onClick={loadData}>
              Refresh Data
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default KubernetesManager
