// ========== PicFlow 管理后台类型定义 ==========

/** 用户 */
export interface User {
  id: number
  username: string
  nickname: string
  avatarUrl?: string
  bio?: string
  role: 'user' | 'admin'
  status: 'active' | 'banned'
  createdAt: string
  updatedAt: string
}

/** 作品 */
export interface Artwork {
  id: number
  userId: number
  title: string
  description?: string
  imageUrl: string
  thumbnailUrl?: string
  tags: string[]
  frameType?: string
  aspectRatio?: string
  bgColor?: string
  watermarkText?: string
  likesCount: number
  favoritesCount: number
  commentsCount: number
  viewsCount: number
  status: 'published' | 'review' | 'removed'
  isFeatured: boolean
  createdAt: string
  updatedAt: string
  author?: { id: number; nickname: string; avatarUrl?: string }
}

/** 通知/公告 */
export interface Notification {
  id: number
  title: string
  content?: string
  target: string
  createdAt: string
}

/** 仪表盘统计数据 */
export interface DashboardStats {
  totalArtworks: number
  totalUsers: number
  todayNew: number
}

/** 分页响应 */
export interface PageResult<T> {
  total: number
  page: number
  size: number
  items: T[]
}

/** 通用 API 响应 */
export interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

/** App 版本 */
export interface AppVersion {
  id: number
  versionName: string
  versionCode: number
  channel: string
  grayPercent: number
  minVersionCode: number
  maxVersionCode: number
  forceUpdate: boolean
  description?: string
  releaseNotes?: string
  downloadUrl?: string
  hotfixUrl?: string
  platform: string
  enabled: boolean
  createdAt: string
}
