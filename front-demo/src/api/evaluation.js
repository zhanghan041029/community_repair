import request from '@/utils/request'

export function createEvaluation(data) {
  return request({ url: '/api/evaluations', method: 'post', data })
}

export function getEvaluationByRepairId(repairId) {
  return request({ url: `/api/evaluations/repair/${repairId}`, method: 'get' })
}

export function getMyEvaluations(params) {
  return request({ url: '/api/evaluations/my', method: 'get', params })
}

export function replyEvaluation(data) {
  return request({ url: '/api/evaluations/reply', method: 'put', data })
}