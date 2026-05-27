<template>
  <div>
    <el-card shadow="never">
      <template #header>
        <div style="display: flex; justify-content: space-between; align-items: center">
          <span>App 版本管理</span>
          <el-button type="primary" size="small" @click="openCreate">发布新版本</el-button>
        </div>
      </template>

      <el-table :data="versions" v-loading="loading" stripe style="width: 100%">
        <el-table-column prop="versionName" label="版本号" width="100" />
        <el-table-column prop="versionCode" label="版本码" width="70" align="center" />
        <el-table-column label="渠道" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="channelType(row.channel)" size="small">{{ row.channel }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="灰度" width="70" align="center">
          <template #default="{ row }">{{ row.grayPercent ?? 100 }}%</template>
        </el-table-column>
        <el-table-column label="适版区间" width="130">
          <template #default="{ row }">{{ row.minVersionCode ?? 0 }} ~ {{ row.maxVersionCode ?? '∞' }}</template>
        </el-table-column>
        <el-table-column label="更新类型" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.forceUpdate ? 'danger' : 'warning'" size="small">
              {{ row.forceUpdate ? '强制' : '可选' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="70" align="center">
          <template #default="{ row }">
            <el-tag :type="row.enabled ? 'success' : 'info'" size="small">
              {{ row.enabled ? '启用' : '下架' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="说明" min-width="200" show-overflow-tooltip />
        <el-table-column prop="platform" label="平台" width="80" align="center" />
        <el-table-column prop="createdAt" label="发布时间" width="160">
          <template #default="{ row }">{{ formatTime(row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="openEdit(row)">编辑</el-button>
            <el-button size="small" :type="row.enabled ? 'warning' : 'success'" @click="toggleEnabled(row)">
              {{ row.enabled ? '下架' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="showDialog" :title="isEdit ? '编辑版本' : '发布新版本'" width="620px">
      <el-form :model="form" label-width="110px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="版本号">
              <el-input v-model="form.versionName" placeholder="如 1.1.0" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="版本码">
              <el-input-number v-model="form.versionCode" :min="1" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="渠道">
              <el-select v-model="form.channel" style="width: 100%">
                <el-option label="稳定版 (stable)" value="stable" />
                <el-option label="测试版 (beta)" value="beta" />
                <el-option label="内部版 (alpha)" value="alpha" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="灰度比例">
              <el-slider v-model="form.grayPercent" :min="0" :max="100" show-input />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="适用版本下限">
              <el-input-number v-model="form.minVersionCode" :min="0" style="width: 100%" />
              <div style="font-size:12px;color:#999;margin-top:4px">低于此版本强制更新</div>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="适用版本上限">
              <el-input-number v-model="form.maxVersionCode" :min="1" :max="999999" style="width: 100%" />
              <div style="font-size:12px;color:#999;margin-top:4px">高于此版本不弹提示</div>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="目标平台">
          <el-radio-group v-model="form.platform">
            <el-radio value="all">全部</el-radio>
            <el-radio value="android">Android</el-radio>
            <el-radio value="ios">iOS</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="更新类型">
          <el-radio-group v-model="form.forceUpdate">
            <el-radio :value="false">可选更新</el-radio>
            <el-radio :value="true">强制更新</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="更新说明">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="简短更新说明" />
        </el-form-item>
        <el-form-item label="发布日志">
          <el-input v-model="form.releaseNotes" type="textarea" :rows="4" placeholder="详细发布日志，支持 Markdown" />
        </el-form-item>
        <el-form-item label="下载链接">
          <el-input v-model="form.downloadUrl" placeholder="安装包下载地址" />
        </el-form-item>
        <el-form-item label="热更新链接">
          <el-input v-model="form.hotfixUrl" placeholder="Shorebird 热更新补丁地址" />
          <div style="font-size:12px;color:#999;margin-top:4px">可通过 Shorebird CodePush 推送 Dart 代码更新</div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import { formatTime } from '@/utils/format'
import { getVersions, createVersion, updateVersion, deleteVersion } from '@/api/versions'
import type { AppVersion } from '@/types'

const loading = ref(false)
const versions = ref<AppVersion[]>([])
const showDialog = ref(false)
const submitting = ref(false)
const isEdit = ref(false)
const editId = ref<number | null>(null)

const defaultForm = {
  versionName: '', versionCode: 1, channel: 'stable',
  grayPercent: 100, minVersionCode: 0, maxVersionCode: 999999,
  forceUpdate: false, description: '', releaseNotes: '',
  downloadUrl: '', hotfixUrl: '', platform: 'all',
}
const form = reactive({ ...defaultForm })

function channelType(ch: string) {
  if (ch === 'stable') return 'success'
  if (ch === 'beta') return 'warning'
  return 'danger'
}

async function loadData() {
  loading.value = true
  try {
    const res = await getVersions()
    if (res.code === 0) versions.value = res.data || []
  } finally { loading.value = false }
}

function openCreate() {
  isEdit.value = false; editId.value = null
  Object.assign(form, defaultForm)
  showDialog.value = true
}

function openEdit(row: AppVersion) {
  isEdit.value = true; editId.value = row.id
  Object.assign(form, row)
  showDialog.value = true
}

async function handleSubmit() {
  if (!form.versionName.trim()) { ElMessage.warning('请输入版本号'); return }
  submitting.value = true
  try {
    if (isEdit.value && editId.value) {
      await updateVersion(editId.value, form)
      ElMessage.success('更新成功')
    } else {
      await createVersion(form)
      ElMessage.success('发布成功')
    }
    showDialog.value = false
    loadData()
  } catch { ElMessage.error(isEdit.value ? '更新失败' : '发布失败') }
  finally { submitting.value = false }
}

async function toggleEnabled(row: AppVersion) {
  try {
    await updateVersion(row.id, { ...row, enabled: !row.enabled })
    ElMessage.success(row.enabled ? '已下架' : '已启用')
    loadData()
  } catch { ElMessage.error('操作失败') }
}

onMounted(loadData)
</script>
