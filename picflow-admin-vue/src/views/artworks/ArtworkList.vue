<template>
  <div>
    <el-card shadow="never">
      <el-table :data="artworks" v-loading="loading" stripe style="width: 100%">
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="title" label="标题" min-width="160" />
        <el-table-column label="作者" width="120">
          <template #default="{ row }">
            {{ row.author?.nickname || '匿名' }}
          </template>
        </el-table-column>
        <el-table-column prop="likesCount" label="点赞" width="70" align="center" />
        <el-table-column prop="commentsCount" label="评论" width="70" align="center" />
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)" size="small">
              {{ statusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="isFeatured" label="精选" width="70" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.isFeatured" type="warning" size="small">是</el-tag>
            <span v-else style="color:#999">—</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleReview(row, 'published')">通过</el-button>
            <el-button size="small" type="danger" @click="handleReview(row, 'removed')">下架</el-button>
            <el-button
              size="small"
              :type="row.isFeatured ? 'info' : 'warning'"
              @click="handleFeatured(row)"
            >
              {{ row.isFeatured ? '取消精选' : '精选' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getArtworks, reviewArtwork, setFeatured, removeArtwork } from '@/api/artworks'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { Artwork } from '@/types'

const loading = ref(false)
const artworks = ref<Artwork[]>([])

function statusType(s: string) {
  if (s === 'published') return 'success'
  if (s === 'removed') return 'danger'
  return 'info'
}
function statusLabel(s: string) {
  if (s === 'published') return '已发布'
  if (s === 'removed') return '已下架'
  return '待审核'
}

async function loadData() {
  loading.value = true
  try {
    const res = await getArtworks()
    if (res.code === 0) artworks.value = res.data || []
  } catch {} finally { loading.value = false }
}

async function handleReview(row: Artwork, status: string) {
  try {
    await reviewArtwork(row.id, status)
    ElMessage.success(status === 'published' ? '已通过' : '已下架')
    loadData()
  } catch {
    ElMessage.error('操作失败')
  }
}

async function handleFeatured(row: Artwork) {
  try {
    const newVal = !row.isFeatured
    await setFeatured(row.id, newVal)
    ElMessage.success(newVal ? '已设为精选' : '已取消精选')
    loadData()
  } catch {
    ElMessage.error('操作失败')
  }
}

onMounted(loadData)
</script>
