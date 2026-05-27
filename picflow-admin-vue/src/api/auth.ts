import { post, get, put } from './index'
import type { ApiResponse, User } from '@/types'

/** 登录：POST /auth/login */
export function login(username: string, password: string) {
  return post<{ token: string; user: User }>('/auth/login', { username, password })
}

/** 获取当前用户信息：GET /auth/profile */
export function getProfile() {
  return get<User>('/auth/profile')
}

/** 修改个人资料：PUT /auth/profile */
export function updateProfile(data: { nickname?: string; bio?: string }) {
  return put<User>('/auth/profile', data)
}
