import request from '@/utils/request'

export function listRepairs(params) {
  return request({ url: '/api/repairs', method: 'get', params })
}

export function createRepair(data) {
  return request({ url: '/api/repairs', method: 'post', data })
}

export function getRepairDetail(id) {
  return request({ url: `/api/repairs/${id}`, method: 'get' })
}

export function updateRepair(data) {
  return request({ url: '/api/repairs', method: 'put', data })
}

export function cancelRepair(id) {
  return request({ url: `/api/repairs/${id}`, method: 'delete' })
}

export function assignRepair(data) {
  return request({ url: '/api/repairs/assign', method: 'post', data })
}

export function updateRepairStatus(data) {
  return request({ url: '/api/repairs/status', method: 'put', data })
}

export function getRepairStats() {
  return request({ url: '/api/repairs/stats', method: 'get' })
}

export function getAdminDashboardStats() {
  return request({ url: '/api/repairs/admin/dashboard', method: 'get' })
}

export function uploadRepairImage(file) {
  const formData = new FormData()
  formData.append('file', file)
  return request({ url: '/api/uploads/repair', method: 'post', data: formData, headers: { 'Content-Type': 'multipart/form-data' } })
}