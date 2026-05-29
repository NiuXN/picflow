<template>
  <div>
    <el-card shadow="never">
      <template #header>
        <div style="display: flex; justify-content: space-between; align-items: center">
          <span>相框/滤镜配置</span>
          <div>
            <el-radio-group v-model="currentType" style="margin-right: 16px" @change="loadData">
              <el-radio-button value="frame">相框</el-radio-button>
              <el-radio-button value="filter">滤镜</el-radio-button>
            </el-radio-group>
            <el-button type="primary" size="small" @click="openCreate">新增配置</el-button>
          </div>
        </div>
      </template>

      <el-table :data="configs" v-loading="loading" stripe style="width: 100%">
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="configKey" label="键名" width="120" />
        <el-table-column prop="label" label="显示名称" width="120" />
        <el-table-column prop="description" label="描述" min-width="150" show-overflow-tooltip />
        <el-table-column prop="sortOrder" label="排序" width="70" align="center" />
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-switch v-model="row.enabled" @change="toggleEnabled(row)" />
          </template>
        </el-table-column>
        <el-table-column label="配置值" min-width="250" show-overflow-tooltip>
          <template #default="{ row }">
            <code style="font-size: 12px">{{ row.configValue }}</code>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="openEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="showDialog" :title="isEdit ? '编辑配置' : '新增配置'" width="580px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="配置类型">
          <el-select v-model="form.configType" :disabled="isEdit" style="width: 100%">
            <el-option label="相框 (frame)" value="frame" />
            <el-option label="滤镜 (filter)" value="filter" />
          </el-select>
        </el-form-item>
        <el-form-item label="键名">
          <el-input v-model="form.configKey" placeholder="如：minimal, cream" :disabled="isEdit" />
        </el-form-item>
        <el-form-item label="显示名称">
          <el-input v-model="form.label" placeholder="如：极简留白" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" placeholder="副标题描述" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sortOrder" :min="0" :max="9999" style="width: 100%" />
        </el-form-item>
        <el-form-item label="配置值">
          <el-input v-model="form.configValue" type="textarea" :rows="4" placeholder='JSON格式，如 {"isPro":false} 或 {"matrix":[...]}' />
          <div style="font-size:12px;color:#999;margin-top:4px">
            相框: <code>{"isPro":false}</code> &nbsp;|&nbsp;
            滤镜: <code>{"matrix":[20个数值]}</code>
          </div>
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
import { getConfigs, createConfig, updateConfig, deleteConfig } from '@/api/configs'
import type { ConfigItem } from '@/api/configs'

const loading = ref(false)
const configs = ref<ConfigItem[]>([])
const showDialog = ref(false)
const submitting = ref(false)
const isEdit = ref(false)
const editId = ref<number | null>(null)
const currentType = ref('frame')

const defaultForm = {
  configType: 'frame', configKey: '', configValue: '',
  label: '', description: '', sortOrder: 0,
}
const form = reactive({ ...defaultForm })

async function loadData() {
  loading.value = true
  try {
    const res = await getConfigs(currentType.value)
    if (res.code === 0) configs.value = res.data || []
  } catch {} finally { loading.value = false }
}

function openCreate() {
  isEdit.value = false
  editId.value = null
  Object.assign(form, { ...defaultForm, configType: currentType.value })
  showDialog.value = true
}

function openEdit(row: ConfigItem) {
  isEdit.value = true
  editId.value = row.id
  Object.assign(form, {
    configType: row.configType, configKey: row.configKey,
    configValue: row.configValue, label: row.label,
    description: row.description || '', sortOrder: row.sortOrder,
  })
  showDialog.value = true
}

async function handleSubmit() {
  if (!form.configKey.trim()) { ElMessage.warning('请输入键名'); return }
  if (!form.label.trim()) { ElMessage.warning('请输入显示名称'); return }
  submitting.value = true
  try {
    if (isEdit.value && editId.value) {
      await updateConfig(editId.value, form)
      ElMessage.success('更新成功')
    } else {
      await createConfig(form)
      ElMessage.success('创建成功')
    }
    showDialog.value = false
    loadData()
  } catch { ElMessage.error('操作失败') }
  finally { submitting.value = false }
}

async function toggleEnabled(row: ConfigItem) {
  try {
    await updateConfig(row.id, { enabled: row.enabled })
    ElMessage.success(row.enabled ? '已启用' : '已禁用')
  } catch {
    row.enabled = !row.enabled
    ElMessage.error('操作失败')
  }
}

async function handleDelete(row: ConfigItem) {
  try {
    await ElMessageBox.confirm(`确定删除配置「${row.label}」？`, '提示', { type: 'warning' })
    await deleteConfig(row.id)
    ElMessage.success('已删除')
    loadData()
  } catch {}
}

onMounted(loadData)
</script>
