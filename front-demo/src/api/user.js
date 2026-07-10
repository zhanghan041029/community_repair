import request from '@/utils/request'

export function login(data) {
  return request({ url: '/api/login', method: 'post', data })
}

export function registerResident(data) {
  return request({ url: '/api/users/register', method: 'post', data })
}

export function getCurrentUser() {
  return request({ url: '/api/users/current', method: 'get' })
}

export function uploadAvatar(formData) {
  return request({
    url: '/api/users/avatar',
    method: 'post',
    data: formData
  })
}

export function updateProfile(data) {
  return request({ url: '/api/users/profile', method: 'put', data })
}

export function changePassword(data) {
  return request({ url: '/api/users/password', method: 'put', data })
}

export function resetPassword(data) {
  return request({ url: '/api/users/reset-password', method: 'post', data })
}