import { get, post, put, del } from './index'
import type { ApiResponse } from '@/types'

export interface TagItem {
  id: number
  name: string
  description?: string
  sortOrder: number
  enabled: boolean
  createdAt: string
}

/** 获取标签列表：GET /admin/tags */
export function getTags() {
  return get<TagItem[]>('/admin/tags')
}

/** 创建标签：POST /admin/tags */
export function createTag(data: { name: string; description?: string; sortOrder?: number }) {
  return post<TagItem>('/admin/tags', data)
}

/** 更新标签：PUT /admin/tags/:id */
export function updateTag(id: number, data: Partial<TagItem>) {
  return put<TagItem>(`/admin/tags/${id}`, data)
}

/** 删除标签：DELETE /admin/tags/:id */
export function deleteTag(id: number) {
  return del<{ message: string }>(`/admin/tags/${id}`)
}
