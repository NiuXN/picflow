import { get, post } from './index'
import type { ApiResponse, Notification } from '@/types'

/** 获取通知列表：GET /notifications */
export async function getNotifications() {
  const res = await get<{ items: Notification[] }>('/notifications')
  return { ...res, data: res.data?.items ?? [] }
}

/** 发布通知：POST /admin/notifications */
export function createNotification(title: string, content: string) {
  return post<Notification>('/admin/notifications', { title, content })
}
