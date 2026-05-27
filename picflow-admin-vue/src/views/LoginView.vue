<template>
  <div class="login-page">
    <div class="login-left">
      <div class="brand">
        <div class="brand-icon">✧</div>
        <h1 class="brand-name">PicFlow</h1>
        <p class="brand-desc">创作广场 · 管理后台</p>
      </div>
    </div>
    <div class="login-right">
      <div class="login-card">
        <h2 class="title">欢迎回来</h2>
        <p class="subtitle">请使用管理员账号登录</p>
        <el-form ref="formRef" :model="form" :rules="rules" @keyup.enter="handleLogin">
          <el-form-item prop="username">
            <el-input
              v-model="form.username"
              placeholder="用户名"
              prefix-icon="User"
              size="large"
            />
          </el-form-item>
          <el-form-item prop="password">
            <el-input
              v-model="form.password"
              type="password"
              placeholder="密码"
              prefix-icon="Lock"
              size="large"
              show-password
            />
          </el-form-item>
          <el-form-item>
            <el-button
              type="primary"
              size="large"
              :loading="loading"
              style="width: 100%"
              @click="handleLogin"
            >
              {{ loading ? '登录中...' : '登 录' }}
            </el-button>
          </el-form-item>
        </el-form>
        <p v-if="error" class="error">{{ error }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

const router = useRouter()
const auth = useAuthStore()
const formRef = ref<FormInstance>()
const loading = ref(false)
const error = ref('')

const form = reactive({ username: '', password: '' })
const rules: FormRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
}

async function handleLogin() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  error.value = ''
  try {
    const res = await auth.login(form.username, form.password)
    if (res.code === 0) {
      ElMessage.success('登录成功')
      router.push('/dashboard')
    } else {
      error.value = res.message || '登录失败'
    }
  } catch (e: any) {
    error.value = e?.response?.data?.message || '网络错误，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  height: 100vh;
  display: flex;
}
.login-left {
  width: 45%;
  background: linear-gradient(135deg, #1e1e2d 0%, #2a2a40 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}
.brand { text-align: center; color: #fff; }
.brand-icon { font-size: 64px; margin-bottom: 16px; }
.brand-name { font-size: 32px; font-weight: 700; margin: 0; }
.brand-desc { font-size: 14px; opacity: 0.6; margin-top: 8px; }
.login-right {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f6fa;
}
.login-card {
  width: 380px;
  padding: 40px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.08);
}
.title { font-size: 24px; font-weight: 700; color: #333; margin: 0; }
.subtitle { color: #999; font-size: 14px; margin: 8px 0 32px; }
.error { text-align: center; color: #f56c6c; font-size: 13px; margin: 0; }
</style>
