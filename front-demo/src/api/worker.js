import request from '@/utils/request'

export function registerWorker(data) {
  return request({ url: '/api/workers/register', method: 'post', data })
}

export function addWorker(data) {
  return request({ url: '/api/workers', method: 'post', data })
}

export function listWorkers(params) {
  return request({ url: '/api/workers', method: 'get', params })
}

export function reviewWorker(data) {
  return request({ url: '/api/workers/review', method: 'put', data })
}

export function deleteWorker(id) {
  return request({ url: `/api/workers/${id}`, method: 'delete' })
}

export function listActiveWorkers(params) {
  return request({ url: '/api/workers/active', method: 'get', params })
}