import request from '@/utils/request'

export function createAnnouncement(data) {
  return request({ url: '/api/announcements', method: 'post', data })
}

export function listAnnouncements() {
  return request({ url: '/api/announcements', method: 'get' })
}

export function getAnnouncementDetail(id) {
  return request({ url: `/api/announcements/${id}`, method: 'get' })
}

export function deleteAnnouncement(id) {
  return request({ url: `/api/announcements/${id}`, method: 'delete' })
}
