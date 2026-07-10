import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as loginApi } from '@/api/user'
import request from '@/utils/request'

function isTokenExpired(token) {
  if (!token) return true
  try {
    const payload = JSON.parse(atob(token.split('.')[1]))
    const exp = payload.exp * 1000
    return Date.now() >= exp
  } catch {
    return true
  }
}

export const useUserStore = defineStore('user', () => {
  const token = ref('')
  const userId = ref(null)
  const role = ref('')
  const userInfo = ref(null)

  const isLoggedIn = computed(() => !!token.value && !isTokenExpired(token.value))

  async function login(credentials) {
    const res = await loginApi(credentials)
    token.value = res.data.token
    userId.value = res.data.userId
    role.value = res.data.role
    if (res.data.avatar) {
      userInfo.value = { ...res.data }
    }
    return res.data
  }

  async function fetchCurrentUser() {
    if (!token.value) return
    try {
      const res = await request({ url: '/api/users/current', method: 'get' })
      userInfo.value = res.data
      role.value = res.data.role
      userId.value = res.data.id
    } catch {
      // ignore
    }
  }

  function logout() {
    token.value = ''
    userId.value = null
    role.value = ''
    userInfo.value = null
  }

  return {
    token,
    userId,
    role,
    userInfo,
    isLoggedIn,
    login,
    fetchCurrentUser,
    logout
  }
}, {
  persist: {
    key: 'community-repair-user',
    storage: localStorage,
    paths: ['token', 'userId', 'role']
  }
})