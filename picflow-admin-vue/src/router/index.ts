import { createRouter, createWebHashHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/LoginView.vue'),
    },
    {
      path: '/',
      component: () => import('@/layouts/AdminLayout.vue'),
      redirect: '/dashboard',
      children: [
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: () => import('@/views/DashboardView.vue'),
          meta: { title: '仪表盘' },
        },
        {
          path: 'artworks',
          name: 'Artworks',
          component: () => import('@/views/artworks/ArtworkList.vue'),
          meta: { title: '作品管理' },
        },
        {
          path: 'users',
          name: 'Users',
          component: () => import('@/views/users/UserList.vue'),
          meta: { title: '用户管理' },
        },
        {
          path: 'notifications',
          name: 'Notifications',
          component: () => import('@/views/notifications/NoticeList.vue'),
          meta: { title: '通知管理' },
        },
        {
          path: 'versions',
          name: 'Versions',
          component: () => import('@/views/versions/VersionList.vue'),
          meta: { title: '版本管理' },
        },
        {
          path: 'tags',
          name: 'Tags',
          component: () => import('@/views/config/TagList.vue'),
          meta: { title: '标签管理' },
        },
        {
          path: 'configs',
          name: 'Configs',
          component: () => import('@/views/config/ConfigList.vue'),
          meta: { title: '配置管理' },
        },
      ],
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'NotFound',
      component: () => import('@/views/LoginView.vue'),
      meta: { title: '页面不存在' },
    },
  ],
})

router.beforeEach((to, _from, next) => {
  const auth = useAuthStore()
  if (to.path !== '/login' && !auth.isLoggedIn) {
    next('/login')
  } else if (to.path === '/login' && auth.isLoggedIn) {
    next('/dashboard')
  } else {
    next()
  }
})

export default router
