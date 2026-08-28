import React, { useState } from 'react'
import { BrowserRouter as Router, Routes, Route, Link, useLocation, Navigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './context/AuthContext'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import CostOptimizer from './pages/CostOptimizer'
import KubernetesManager from './pages/KubernetesManager'
import IncidentManager from './pages/IncidentManager'
import AutomationService from './pages/AutomationService'
import ChatOps from './pages/ChatOps'
import Metrics from './pages/Metrics'
import UserManagement from './pages/UserManagement'
import UserGuide from './pages/UserGuide'
import './styles/App.css'

// Protected Route Component
function ProtectedRoute({ children }) {
  const { isAuthenticated, loading } = useAuth()

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner-large"></div>
        <p>Loading...</p>
      </div>
    )
  }

  return isAuthenticated ? children : <Navigate to="/login" replace />
}

function Navigation() {
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const [showUserMenu, setShowUserMenu] = useState(false)
  const location = useLocation()
  const { user, logout, isAdmin } = useAuth()

  const navItems = [
    { path: '/', icon: '📊', label: 'Dashboard', color: '#3b82f6' },
    { path: '/cost-optimizer', icon: '💰', label: 'Cost Optimizer', color: '#10b981' },
    { path: '/kubernetes', icon: '☸️', label: 'Kubernetes', color: '#06b6d4' },
    { path: '/incidents', icon: '🚨', label: 'Incidents', color: '#ef4444' },
    { path: '/automation', icon: '🤖', label: 'Automation', color: '#8b5cf6' },
    { path: '/chatops', icon: '💬', label: 'ChatOps', color: '#f59e0b' },
    { path: '/metrics', icon: '📈', label: 'Metrics', color: '#ec4899' },
    ...(isAdmin ? [{ path: '/users', icon: '👥', label: 'Users', color: '#14b8a6' }] : []),
    { path: '/guide', icon: '📚', label: 'User Guide', color: '#6366f1' }
  ]

  const handleLogout = () => {
    logout()
    setShowUserMenu(false)
  }

  return (
    <>
      <div className={`sidebar ${sidebarOpen ? 'open' : 'closed'}`}>
        <div className="sidebar-header">
          <h1 className="sidebar-title">
            {sidebarOpen ? '☁️ CloudOps' : '☁️'}
          </h1>
          <button
            className="sidebar-toggle"
            onClick={() => setSidebarOpen(!sidebarOpen)}
          >
            {sidebarOpen ? '◀' : '▶'}
          </button>
        </div>

        <nav className="sidebar-nav">
          {navItems.map(item => (
            <Link
              key={item.path}
              to={item.path}
              className={`nav-item ${location.pathname === item.path ? 'active' : ''}`}
              style={{ '--item-color': item.color }}
            >
              <span className="nav-icon">{item.icon}</span>
              {sidebarOpen && <span className="nav-label">{item.label}</span>}
            </Link>
          ))}
        </nav>

        {sidebarOpen && (
          <div className="sidebar-footer">
            <div className="user-profile" onClick={() => setShowUserMenu(!showUserMenu)}>
              <div className="user-avatar">
                {user?.full_name?.charAt(0).toUpperCase() || 'U'}
              </div>
              <div className="user-info">
                <div className="user-name">{user?.full_name || 'User'}</div>
                <div className="user-role">{user?.role || 'user'}</div>
              </div>
              <span className="user-menu-icon">⋮</span>
            </div>

            {showUserMenu && (
              <div className="user-menu">
                <div className="user-menu-item">
                  <span>👤</span> {user?.email}
                </div>
                <div className="user-menu-divider"></div>
                <div className="user-menu-item clickable" onClick={handleLogout}>
                  <span>🚪</span> Logout
                </div>
              </div>
            )}

            <div className="status-indicator">
              <span className="status-dot"></span>
              All Systems Operational
            </div>
          </div>
        )}
      </div>

      <div className={`main-content ${sidebarOpen ? '' : 'expanded'}`}>
        <Routes>
          <Route path="/" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
          <Route path="/cost-optimizer" element={<ProtectedRoute><CostOptimizer /></ProtectedRoute>} />
          <Route path="/kubernetes" element={<ProtectedRoute><KubernetesManager /></ProtectedRoute>} />
          <Route path="/incidents" element={<ProtectedRoute><IncidentManager /></ProtectedRoute>} />
          <Route path="/automation" element={<ProtectedRoute><AutomationService /></ProtectedRoute>} />
          <Route path="/chatops" element={<ProtectedRoute><ChatOps /></ProtectedRoute>} />
          <Route path="/metrics" element={<ProtectedRoute><Metrics /></ProtectedRoute>} />
          <Route path="/users" element={<ProtectedRoute><UserManagement /></ProtectedRoute>} />
          <Route path="/guide" element={<ProtectedRoute><UserGuide /></ProtectedRoute>} />
        </Routes>
      </div>
    </>
  )
}

function AppContent() {
  const { isAuthenticated, loading } = useAuth()
  const location = useLocation()

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner-large"></div>
        <p>Loading...</p>
      </div>
    )
  }

  // If user is authenticated and on login page, redirect to dashboard
  if (isAuthenticated && location.pathname === '/login') {
    return <Navigate to="/" replace />
  }

  // If user is not authenticated and not on login page, show login
  if (!isAuthenticated && location.pathname !== '/login') {
    return <Navigate to="/login" replace />
  }

  return location.pathname === '/login' ? (
    <Routes>
      <Route path="/login" element={<Login />} />
    </Routes>
  ) : (
    <Navigation />
  )
}

function App() {
  return (
    <Router>
      <AuthProvider>
        <AppContent />
      </AuthProvider>
    </Router>
  )
}

export default App
