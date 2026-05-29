import { get, post, put, del } from './index'
import type { ApiResponse } from '@/types'

export interface ConfigItem {
  id: number
  configType: string
  configKey: string
  configValue: string
  label: string
  description?: string
  sortOrder: number
  enabled: boolean
  createdAt: string
  updatedAt: string
}

/** 获取配置列表：GET /admin/configs */
export function getConfigs(configType?: string) {
  return get<ConfigItem[]>('/admin/configs', configType ? { configType } : undefined)
}

/** 创建配置：POST /admin/configs */
export function createConfig(data: Partial<ConfigItem>) {
  return post<ConfigItem>('/admin/configs', data)
}

/** 更新配置：PUT /admin/configs/:id */
export function updateConfig(id: number, data: Partial<ConfigItem>) {
  return put<ConfigItem>(`/admin/configs/${id}`, data)
}

/** 删除配置：DELETE /admin/configs/:id */
export function deleteConfig(id: number) {
  return del<{ message: string }>(`/admin/configs/${id}`)
}
