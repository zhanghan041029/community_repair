import request from '@/utils/request'

export function getUnreadCount() {
  return request.get('/api/notifications/unread-count')
}

export function getNotificationList(limit = 10) {
  return request.get('/api/notifications', { params: { limit } })
}

export function markRead(id) {
  return request.post(`/api/notifications/${id}/read`)
}

export function markAllRead() {
  return request.post('/api/notifications/read-all')
}
