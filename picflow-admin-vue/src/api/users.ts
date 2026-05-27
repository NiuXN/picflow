import { get, put } from './index'
import type { ApiResponse, User, PageResult } from '@/types'

/** 获取用户列表：GET /admin/users */
export function getUsers(page = 1, size = 20, status?: string) {
  return get<PageResult<User>>('/admin/users', { page, size, status })
}

/** 封禁/解封用户：PUT /admin/users/{id}/status */
export function updateUserStatus(id: number, status: string) {
  return put<User>(`/admin/users/${id}/status`, { status })
}
