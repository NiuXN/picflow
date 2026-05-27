import { get, post, put, del } from './index'
import type { AppVersion } from '@/types'

export function getVersions() {
  return get<AppVersion[]>('/admin/versions')
}

export function createVersion(data: Partial<AppVersion>) {
  return post<AppVersion>('/admin/versions', data)
}

export function updateVersion(id: number, data: Partial<AppVersion>) {
  return put<AppVersion>(`/admin/versions/${id}`, data)
}

export function deleteVersion(id: number) {
  return del(`/admin/versions/${id}`)
}
