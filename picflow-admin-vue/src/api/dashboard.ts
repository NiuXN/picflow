import { get } from './index'
import type { ApiResponse, DashboardStats } from '@/types'

/** 获取仪表盘统计数据：GET /admin/dashboard */
export function getDashboard() {
  return get<DashboardStats>('/admin/dashboard')
}

/** 获取近7日数据趋势：GET /admin/dashboard/trend */
export function getDashboardTrend() {
  return get<{ dates: string[]; counts: number[] }>('/admin/dashboard/trend')
}
