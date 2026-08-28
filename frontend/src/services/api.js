import axios from 'axios'

const API_BASE_URL = 'http://localhost'

const api = {
  costOptimizer: axios.create({ baseURL: `${API_BASE_URL}:8001` }),
  k8sManager: axios.create({ baseURL: `${API_BASE_URL}:8002` }),
  incidentManager: axios.create({ baseURL: `${API_BASE_URL}:8003` }),
  automation: axios.create({ baseURL: `${API_BASE_URL}:8004` }),
  chatops: axios.create({ baseURL: `${API_BASE_URL}:8005` }),
  metrics: axios.create({ baseURL: `${API_BASE_URL}:8006` })
}

export default api
