<template>
  <div>
    <el-card shadow="never">
      <template #header>
        <div style="display: flex; justify-content: space-between; align-items: center">
          <span>标签管理</span>
          <el-button type="primary" size="small" @click="openCreate">新增标签</el-button>
        </div>
      </template>

      <el-table :data="tags" v-loading="loading" stripe style="width: 100%">
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="name" label="标签名" width="150" />
        <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip />
        <el-table-column prop="sortOrder" label="排序" width="80" align="center" />
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-switch v-model="row.enabled" @change="toggleEnabled(row)" />
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="170">
          <template #default="{ row }">{{ formatTime(row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="openEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="showDialog" :title="isEdit ? '编辑标签' : '新增标签'" width="480px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="标签名">
          <el-input v-model="form.name" placeholder="如：胶片" maxlength="50" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" placeholder="标签描述（可选）" maxlength="200" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sortOrder" :min="0" :max="9999" style="width: 100%" />
          <div style="font-size:12px;color:#999;margin-top:4px">数值越小越靠前</div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { formatTime } from '@/utils/format'
import { getTags, createTag, updateTag, deleteTag } from '@/api/tags'
import type { TagItem } from '@/api/tags'

const loading = ref(false)
const tags = ref<TagItem[]>([])
const showDialog = ref(false)
const submitting = ref(false)
const isEdit = ref(false)
const editId = ref<number | null>(null)

const defaultForm = { name: '', description: '', sortOrder: 0 }
const form = reactive({ ...defaultForm })

async function loadData() {
  loading.value = true
  try {
    const res = await getTags()
    if (res.code === 0) tags.value = res.data || []
  } catch {} finally { loading.value = false }
}

function openCreate() {
  isEdit.value = false
  editId.value = null
  Object.assign(form, defaultForm)
  showDialog.value = true
}

function openEdit(row: TagItem) {
  isEdit.value = true
  editId.value = row.id
  Object.assign(form, { name: row.name, description: row.description || '', sortOrder: row.sortOrder })
  showDialog.value = true
}

async function handleSubmit() {
  if (!form.name.trim()) { ElMessage.warning('请输入标签名'); return }
  submitting.value = true
  try {
    if (isEdit.value && editId.value) {
      await updateTag(editId.value, form)
      ElMessage.success('更新成功')
    } else {
      await createTag(form)
      ElMessage.success('创建成功')
    }
    showDialog.value = false
    loadData()
  } catch { ElMessage.error('操作失败') }
  finally { submitting.value = false }
}

async function toggleEnabled(row: TagItem) {
  try {
    await updateTag(row.id, { enabled: row.enabled })
    ElMessage.success(row.enabled ? '已启用' : '已禁用')
  } catch {
    row.enabled = !row.enabled
    ElMessage.error('操作失败')
  }
}

async function handleDelete(row: TagItem) {
  try {
    await ElMessageBox.confirm(`确定删除标签「${row.name}」？`, '提示', { type: 'warning' })
    await deleteTag(row.id)
    ElMessage.success('已删除')
    loadData()
  } catch {}
}

onMounted(loadData)
</script>
