<template>
  <el-container class="admin-layout">
    <!-- 侧边栏 -->
    <el-aside :width="isCollapsed ? '64px' : '220px'" class="sidebar">
      <div class="logo" :class="{ collapsed: isCollapsed }">
        <span v-if="!isCollapsed">PicFlow 管理</span>
        <span v-else>✧</span>
      </div>
      <el-menu
        :default-active="route.path"
        :collapse="isCollapsed"
        router
        background-color="#1e1e2d"
        text-color="#a2a3b7"
        active-text-color="#fff"
      >
        <el-menu-item index="/dashboard">
          <el-icon><Odometer /></el-icon>
          <template #title>仪表盘</template>
        </el-menu-item>

        <el-sub-menu index="content">
          <template #title>
            <el-icon><Picture /></el-icon>
            <span>内容管理</span>
          </template>
          <el-menu-item index="/artworks">作品管理</el-menu-item>
          <el-menu-item index="/users">用户管理</el-menu-item>
        </el-sub-menu>

        <el-sub-menu index="config">
          <template #title>
            <el-icon><Menu /></el-icon>
            <span>配置管理</span>
          </template>
          <el-menu-item index="/tags">标签管理</el-menu-item>
          <el-menu-item index="/configs">相框/滤镜</el-menu-item>
        </el-sub-menu>

        <el-sub-menu index="system">
          <template #title>
            <el-icon><Setting /></el-icon>
            <span>系统管理</span>
          </template>
          <el-menu-item index="/notifications">通知管理</el-menu-item>
          <el-menu-item index="/versions">版本管理</el-menu-item>
        </el-sub-menu>
      </el-menu>

      <!-- 折叠按钮 -->
      <div class="collapse-btn" @click="toggleCollapse">
        <el-icon><Fold v-if="!isCollapsed" /><Expand v-else /></el-icon>
      </div>
    </el-aside>

    <!-- 主区域 -->
    <el-container>
      <!-- 顶栏 -->
      <el-header>
        <div class="header-left">
          <el-breadcrumb separator="›">
            <el-breadcrumb-item to="/dashboard">首页</el-breadcrumb-item>
            <el-breadcrumb-item v-if="route.meta.title">{{ route.meta.title }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32" :style="{ background: '#d2c4b3' }">
                {{ (auth.user?.nickname || '管')[0] }}
              </el-avatar>
              <span class="user-name">{{ auth.user?.nickname || '管理员' }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人信息</el-dropdown-item>
                <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- 内容区 -->
      <el-main>
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const isCollapsed = ref(false)

function toggleCollapse() { isCollapsed.value = !isCollapsed.value }

function handleCommand(command: string) {
  if (command === 'logout') { auth.logout(); router.push('/login') }
  if (command === 'profile') { /* 预留 */ }
}
</script>

<style scoped>
.admin-layout { height: 100vh; }
.sidebar {
  background: #1e1e2d;
  display: flex;
  flex-direction: column;
  transition: width 0.3s;
  overflow: hidden;
}
.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 18px;
  font-weight: 700;
  letter-spacing: 1px;
  border-bottom: 1px solid rgba(255,255,255,0.06);
  flex-shrink: 0;
  transition: font-size 0.3s;
}
.logo.collapsed { font-size: 24px; }
.el-menu { border-right: none; flex: 1; overflow-y: auto; }
.collapse-btn {
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #a2a3b7;
  cursor: pointer;
  border-top: 1px solid rgba(255,255,255,0.06);
  flex-shrink: 0;
  transition: color 0.2s;
}
.collapse-btn:hover { color: #fff; }
.el-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
  padding: 0 24px;
  height: 60px;
}
.header-left { display: flex; align-items: center; }
.header-right { display: flex; align-items: center; gap: 16px; }
.user-info {
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
}
.user-name { font-size: 14px; }
.el-main {
  background: #f5f6fa;
  padding: 24px;
  overflow-y: auto;
}

/* 页面过渡动画 */
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
