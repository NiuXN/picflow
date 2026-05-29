<template>
  <div class="dashboard">
    <!-- 统计卡片 -->
    <el-row :gutter="20">
      <el-col :span="8" v-for="item in statCards" :key="item.label">
        <el-card shadow="never" class="stat-card" :style="{ borderLeft: `4px solid ${item.color}` }">
          <div class="stat-body">
            <div>
              <div class="stat-label">{{ item.label }}</div>
              <div class="stat-value">{{ loading ? '—' : item.value }}</div>
            </div>
            <el-icon :size="40" :style="{ color: item.color + '30' }">
              <component :is="item.icon" />
            </el-icon>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表 -->
    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-header">
          <span>数据趋势</span>
          <el-tag size="small" type="info">近7日</el-tag>
        </div>
      </template>
      <div v-if="loading" class="chart-skeleton">
        <el-skeleton :rows="6" animated />
      </div>
      <v-chart v-else :option="chartOption" style="height: 300px" autoresize />
    </el-card>

    <!-- 快捷入口 -->
    <el-card shadow="never" class="section-card">
      <template #header><span>快捷入口</span></template>
      <el-row :gutter="16">
        <el-col :span="4" v-for="item in quickLinks" :key="item.path">
          <el-card shadow="hover" class="quick-link" @click="router.push(item.path)">
            <div class="ql-icon" :style="{ background: item.bg }">{{ item.emoji }}</div>
            <div class="ql-label">{{ item.label }}</div>
            <div class="ql-desc">{{ item.desc }}</div>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { getDashboard, getDashboardTrend } from '@/api/dashboard'
import type { DashboardStats } from '@/types'
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart, BarChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'

use([CanvasRenderer, LineChart, BarChart, GridComponent, TooltipComponent, LegendComponent])

const router = useRouter()
const loading = ref(true)
const stats = ref<DashboardStats>({ totalUsers: 0, totalArtworks: 0, todayNew: 0 })
const trendDates = ref<string[]>([])
const trendCounts = ref<number[]>([])

const statCards = computed(() => [
  { label: '用户总数', value: stats.value.totalUsers, icon: 'User', color: '#409eff' },
  { label: '作品总数', value: stats.value.totalArtworks, icon: 'Picture', color: '#67c23a' },
  { label: '今日新增', value: stats.value.todayNew, icon: 'TrendCharts', color: '#e6a23c' },
])

const quickLinks = [
  { path: '/artworks', label: '作品审核', desc: '管理用户作品', emoji: '📷', bg: '#ecf5ff' },
  { path: '/users', label: '用户管理', desc: '查看/封禁用户', emoji: '👥', bg: '#f0f9eb' },
  { path: '/tags', label: '标签管理', desc: '配置App标签', emoji: '🏷️', bg: '#fdf6ec' },
  { path: '/configs', label: '相框/滤镜', desc: '配置App功能', emoji: '🎨', bg: '#f5f0ff' },
  { path: '/notifications', label: '发布通知', desc: '推送公告消息', emoji: '📢', bg: '#fef0f0' },
  { path: '/versions', label: '版本管理', desc: '发布App版本', emoji: '🚀', bg: '#f0f9eb' },
]

const chartOption = computed(() => ({
  tooltip: { trigger: 'axis' },
  grid: { left: 50, right: 20, bottom: 30, top: 10 },
  xAxis: { type: 'category', data: trendDates.value },
  yAxis: { type: 'value', minInterval: 1 },
  series: [{
    name: '新增作品',
    type: 'bar',
    data: trendCounts.value,
    itemStyle: { color: '#409eff', borderRadius: [6, 6, 0, 0] },
  }],
}))

onMounted(async () => {
  try {
    const [statsRes, trendRes] = await Promise.all([getDashboard(), getDashboardTrend()])
    if (statsRes.code === 0 && statsRes.data) stats.value = statsRes.data
    if (trendRes.code === 0 && trendRes.data) {
      trendDates.value = trendRes.data.dates
      trendCounts.value = trendRes.data.counts
    }
  } catch {}
  finally { loading.value = false }
})
</script>

<style scoped>
.stat-card { margin-bottom: 8px; }
.stat-body { display: flex; justify-content: space-between; align-items: center; }
.stat-label { font-size: 14px; color: #999; margin-bottom: 8px; }
.stat-value { font-size: 32px; font-weight: 700; color: #333; }
.section-card { margin-top: 20px; }
.section-header { display: flex; align-items: center; gap: 12px; }
.chart-skeleton { padding: 20px; }

.quick-link {
  cursor: pointer;
  text-align: center;
  padding: 8px;
  transition: transform 0.2s, box-shadow 0.2s;
}
.quick-link:hover { transform: translateY(-2px); }
.ql-icon {
  width: 48px; height: 48px;
  border-radius: 12px;
  display: flex; align-items: center; justify-content: center;
  font-size: 22px;
  margin: 0 auto 8px;
}
.ql-label { font-size: 14px; font-weight: 600; color: #333; margin-bottom: 4px; }
.ql-desc { font-size: 12px; color: #999; }
</style>
