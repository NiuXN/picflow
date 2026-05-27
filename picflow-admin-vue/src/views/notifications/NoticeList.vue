<template>
  <div>
    <el-card shadow="never">
      <template #header>
        <div style="display: flex; justify-content: space-between; align-items: center">
          <span>通知列表</span>
          <el-button type="primary" size="small" @click="showDialog = true">发布通知</el-button>
        </div>
      </template>

      <el-table :data="notifications" v-loading="loading" stripe style="width: 100%">
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="title" label="标题" min-width="200" />
        <el-table-column prop="content" label="内容" min-width="300" show-overflow-tooltip />
        <el-table-column prop="createdAt" label="发布时间" width="170">
          <template #default="{ row }">{{ formatTime(row.createdAt) }}</template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="showDialog" title="发布通知" width="500px">
      <el-form :model="form" label-width="60px">
        <el-form-item label="标题">
          <el-input v-model="form.title" placeholder="通知标题" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input
            v-model="form.content"
            type="textarea"
            :rows="4"
            placeholder="通知内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleCreate">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue'
import { getNotifications, createNotification } from '@/api/notifications'
import { ElMessage } from 'element-plus'
import type { Notification } from '@/types'
import { formatTime } from '@/utils/format'

const loading = ref(false)
const notifications = ref<Notification[]>([])
const showDialog = ref(false)
const submitting = ref(false)
const form = reactive({ title: '', content: '' })

async function loadData() {
  loading.value = true
  try {
    const res = await getNotifications()
    if (res.code === 0) notifications.value = res.data || []
  } catch {} finally { loading.value = false }
}

async function handleCreate() {
  if (!form.title.trim()) {
    ElMessage.warning('请输入标题')
    return
  }
  submitting.value = true
  try {
    const res = await createNotification(form.title, form.content)
    if (res.code === 0) {
      ElMessage.success('发布成功')
      showDialog.value = false
      form.title = ''
      form.content = ''
      loadData()
    }
  } catch {
    ElMessage.error('发布失败')
  } finally { submitting.value = false }
}

onMounted(loadData)
</script>
