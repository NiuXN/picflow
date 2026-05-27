import axios from 'axios'
import type { ApiResponse } from '@/types'
import { useAuthStore } from '@/stores/auth'

/** Axios 实例：基础路径 /v1，自动注入 JWT Token */
const http = axios.create({
  baseURL: '/v1',
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' },
})

/** 请求拦截器：自动附 Authorization Header */
http.interceptors.request.use((config) => {
  const token = localStorage.getItem('picflow_admin_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

/** 响应拦截器：401 自动跳转登录页 */
http.interceptors.response.use(
  (res) => res,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('picflow_admin_token')
      window.location.href = '/#/login'
    }
    return Promise.reject(error)
  },
)

/** GET 请求 */
export async function get<T>(url: string, params?: Record<string, any>): Promise<ApiResponse<T>> {
  const res = await http.get<ApiResponse<T>>(url, { params })
  return res.data
}

/** POST 请求 */
export async function post<T>(url: string, data?: any): Promise<ApiResponse<T>> {
  const res = await http.post<ApiResponse<T>>(url, data)
  return res.data
}

/** PUT 请求 */
export async function put<T>(url: string, data?: any): Promise<ApiResponse<T>> {
  const res = await http.put<ApiResponse<T>>(url, data)
  return res.data
}

/** DELETE 请求 */
export async function del<T>(url: string): Promise<ApiResponse<T>> {
  const res = await http.delete<ApiResponse<T>>(url)
  return res.data
}

export default http
