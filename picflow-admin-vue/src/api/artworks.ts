import { get, put, del } from './index'
import type { ApiResponse, Artwork } from '@/types'

/** 获取作品列表：GET /admin/artworks */
export async function getArtworks(page = 1, size = 20) {
  const res = await get<{ total: number; items: Artwork[] }>('/admin/artworks', { page, size })
  return { ...res, data: res.data?.items ?? [], total: res.data?.total ?? 0 }
}

/** 审核作品：PUT /admin/artworks/{id}/review */
export function reviewArtwork(id: number, status: string) {
  return put(`/admin/artworks/${id}/review`, { status })
}

/** 设置精选：PUT /admin/artworks/{id}/featured */
export function setFeatured(id: number, isFeatured: boolean) {
  return put(`/admin/artworks/${id}/featured`, { isFeatured })
}

/** 下架作品：DELETE /admin/artworks/{id} */
export function removeArtwork(id: number) {
  return del(`/admin/artworks/${id}`)
}
