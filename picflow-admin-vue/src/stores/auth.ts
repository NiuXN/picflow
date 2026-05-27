import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as loginApi } from '@/api/auth'
import type { User } from '@/types'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('picflow_admin_token') || '')
  const user = ref<User | null>(null)

  const isLoggedIn = computed(() => !!token.value)

  async function login(username: string, password: string) {
    const res = await loginApi(username, password)
    if (res.code === 0 && res.data) {
      token.value = res.data.token
      user.value = res.data.user
      localStorage.setItem('picflow_admin_token', res.data.token)
    }
    return res
  }

  function logout() {
    token.value = ''
    user.value = null
    localStorage.removeItem('picflow_admin_token')
  }

  return { token, user, isLoggedIn, login, logout }
})
