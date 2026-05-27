<template>
  <div>
    <el-card shadow="never">
      <div style="margin-bottom: 16px">
        <el-select v-model="statusFilter" placeholder="状态筛选" @change="loadData" style="width: 140px">
          <el-option label="全部" value="" />
          <el-option label="正常" value="active" />
          <el-option label="封禁" value="banned" />
        </el-select>
      </div>

      <el-table :data="users" v-loading="loading" stripe style="width: 100%">
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="nickname" label="昵称" width="140" />
        <el-table-column prop="bio" label="简介" min-width="200" show-overflow-tooltip />
        <el-table-column prop="role" label="角色" width="80" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.role === 'admin'" type="danger" size="small">管理员</el-tag>
            <span v-else style="color:#999">用户</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 'banned' ? 'danger' : 'success'" size="small">
              {{ row.status === 'banned' ? '封禁' : '正常' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="注册时间" width="170">
          <template #default="{ row }">{{ formatTime(row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.role !== 'admin'"
              size="small"
              :type="row.status === 'banned' ? 'success' : 'danger'"
              @click="handleToggleStatus(row)"
            >
              {{ row.status === 'banned' ? '解封' : '封禁' }}
            </el-button>
            <span v-else style="color:#999;font-size:12px">—</span>
          </template>
        </el-table-column>
      </el-table>

      <div style="margin-top: 16px; display: flex; justify-content: flex-end">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="size"
          :total="total"
          layout="prev, pager, next"
          @current-change="loadData"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getUsers, updateUserStatus } from '@/api/users'
import { ElMessage } from 'element-plus'
import type { User } from '@/types'
import { formatTime } from '@/utils/format'

const loading = ref(false)
const users = ref<User[]>([])
const page = ref(1)
const size = ref(20)
const total = ref(0)
const statusFilter = ref('')

async function loadData() {
  loading.value = true
  try {
    const res = await getUsers(page.value, size.value, statusFilter.value || undefined)
    if (res.code === 0 && res.data) {
      users.value = res.data.items || []
      total.value = res.data.total || 0
    }
  } catch {} finally { loading.value = false }
}

async function handleToggleStatus(row: User) {
  const newStatus = row.status === 'banned' ? 'active' : 'banned'
  const label = newStatus === 'banned' ? '封禁' : '解封'
  try {
    await updateUserStatus(row.id, newStatus)
    ElMessage.success(`${label}成功`)
    loadData()
  } catch {
    ElMessage.error(`${label}失败`)
  }
}

onMounted(loadData)
</script>
