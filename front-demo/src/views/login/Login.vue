<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import { registerResident, resetPassword } from '@/api/user'
import { registerWorker } from '@/api/worker'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const formRef = ref(null)
const viewMode = ref('login') // 'login' | 'register'

// ===== 登录表单 =====
const loginForm = reactive({
  username: '',
  password: '',
  role: '',
  rememberAccount: false,
  rememberPassword: false
})

const loginRules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  role: [{ required: true, message: '请选择身份', trigger: 'change' }]
}

async function handleLogin() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    await userStore.login({
      username: loginForm.username,
      password: loginForm.password,
      role: loginForm.role
    })
    localStorage.setItem('last-login-role', loginForm.role)
    if (loginForm.rememberAccount) {
      localStorage.setItem('saved-username', loginForm.username)
    } else {
      localStorage.removeItem('saved-username')
    }
    if (loginForm.rememberPassword) {
      localStorage.setItem('saved-password', loginForm.password)
    } else {
      localStorage.removeItem('saved-password')
    }
    router.push('/')
  } catch {
    // handled by interceptor
  } finally {
    loading.value = false
  }
}

// ===== 忘记密码 =====
const resetVisible = ref(false)
const resetForm = reactive({ username: '', phone: '', newPassword: '' })
const resetLoading = ref(false)

function openResetPwd() {
  resetForm.username = ''
  resetForm.phone = ''
  resetForm.newPassword = ''
  resetVisible.value = true
}

async function handleResetPwd() {
  if (!resetForm.username || !resetForm.phone) {
    ElMessage.warning('请输入用户名和手机号')
    return
  }
  resetLoading.value = true
  try {
    const res = await resetPassword({ username: resetForm.username, phone: resetForm.phone, newPassword: resetForm.newPassword || '123456' })
    ElMessage.success(res.msg || '密码重置成功')
    resetVisible.value = false
  } catch {
    // handled
  } finally {
    resetLoading.value = false
  }
}

// ===== 注册表单 =====
const registerFormRef = ref(null)
const registerLoading = ref(false)
const registerRole = ref('resident') // 'resident' | 'worker'

const registerForm = reactive({
  name: '', username: '', phone: '', address: '', skill: '',
  password: '', confirmPwd: '', idCard: ''
})

const validateConfirm = (rule, value, callback) => {
  if (value !== registerForm.password) callback(new Error('两次密码不一致'))
  else callback()
}

const baseRules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  phone: [{ required: true, message: '请输入手机号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  confirmPwd: [{ required: true, validator: validateConfirm, trigger: 'blur' }]
}

const registerRules = computed(() => {
  if (registerRole.value === 'resident') {
    return {
      ...baseRules,
      address: [{ required: true, message: '请输入居住地址', trigger: 'blur' }]
    }
  } else {
    return {
      ...baseRules,
      skill: [{ required: true, message: '请输入技能特长', trigger: 'blur' }]
    }
  }
})

async function handleRegister() {
  const valid = await registerFormRef.value?.validate().catch(() => false)
  if (!valid) return
  registerLoading.value = true
  try {
    if (registerRole.value === 'resident') {
      await registerResident({
        name: registerForm.name,
        username: registerForm.username,
        phone: registerForm.phone,
        address: registerForm.address,
        password: registerForm.password
      })
      ElMessage.success('注册成功,请登录')
    } else {
      await registerWorker({
        name: registerForm.name,
        phone: registerForm.phone,
        skill: registerForm.skill,
        username: registerForm.username,
        password: registerForm.password,
        idCard: registerForm.idCard || undefined
      })
      ElMessage.success('注册成功,请等待管理员审核')
    }
    viewMode.value = 'login'
  } catch {
    // handled
  } finally {
    registerLoading.value = false
  }
}

function switchView(mode) {
  viewMode.value = mode
}

onMounted(() => {
  const lastRole = localStorage.getItem('last-login-role')
  if (lastRole) {
    loginForm.role = lastRole
  }
  const savedUsername = localStorage.getItem('saved-username')
  if (savedUsername) {
    loginForm.username = savedUsername
    loginForm.rememberAccount = true
  }
  const savedPassword = localStorage.getItem('saved-password')
  if (savedPassword) {
    loginForm.password = savedPassword
    loginForm.rememberPassword = true
  }
})
</script>

<template>
  <div class="login-page">
    <!-- 左侧品牌展示区 -->
    <div class="login-left">
      <div class="brand-logo">
        <div class="logo-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>
          </svg>
        </div>
        <span class="logo-text">社区维修系统平台</span>
      </div>

      <div class="worker-image-card">
        <img src="@/assets/logo1.png" alt="维修工人" class="worker-logo-img" />
      </div>

      <div class="brand-footer">
        <p class="footer-desc">专业维修管理平台</p>
        <p class="footer-slogan">高效 · 智能 · 可靠</p>
      </div>
    </div>

    <!-- 右侧表单区 -->
    <div class="login-right">
      <div class="login-card">

        <!-- ===== 登录视图 ===== -->
        <template v-if="viewMode === 'login'">
          <div class="form-header">
            <h2 class="form-title">欢迎登录</h2>
            <p class="form-subtitle">WELCOME!</p>
          </div>

          <el-form
            ref="formRef"
            :model="loginForm"
            :rules="loginRules"
            class="login-form"
            @keyup.enter="handleLogin"
          >
            <el-form-item prop="role">
              <div class="role-selector login-role-selector">
                <div
                  class="role-option"
                  :class="{ active: loginForm.role === 'resident' }"
                  @click="loginForm.role = 'resident'"
                >
                  <span class="role-icon">🏠</span>
                  <span class="role-name">居民</span>
                </div>
                <div
                  class="role-option"
                  :class="{ active: loginForm.role === 'worker' }"
                  @click="loginForm.role = 'worker'"
                >
                  <span class="role-icon worker-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="20" height="20">
                      <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>
                    </svg>
                  </span>
                  <span class="role-name">维修工</span>
                </div>
                <div
                  class="role-option"
                  :class="{ active: loginForm.role === 'admin' }"
                  @click="loginForm.role = 'admin'"
                >
                  <span class="role-icon">⚙️</span>
                  <span class="role-name">管理员</span>
                </div>
              </div>
            </el-form-item>

            <div class="form-label">账号</div>
            <el-form-item prop="username">
              <el-input
                v-model="loginForm.username"
                placeholder="请输入账号"
                :prefix-icon="User"
                size="large"
              />
            </el-form-item>

            <div class="form-label">密码</div>
            <el-form-item prop="password">
              <el-input
                v-model="loginForm.password"
                type="password"
                placeholder="请输入密码"
                :prefix-icon="Lock"
                size="large"
                show-password
              />
            </el-form-item>

            <div class="remember-row">
              <el-checkbox v-model="loginForm.rememberAccount">记住账号</el-checkbox>
              <el-checkbox v-model="loginForm.rememberPassword">记住密码</el-checkbox>
            </div>

            <div class="forgot-row">
              <el-link type="primary" :underline="false" @click="openResetPwd">忘记密码?</el-link>
            </div>

            <el-form-item>
              <el-button
                type="primary"
                size="large"
                :loading="loading"
                class="login-btn"
                @click="handleLogin"
              >
                立即登录
              </el-button>
            </el-form-item>

            <el-form-item>
              <el-button
                class="register-btn"
                size="large"
                @click="switchView('register')"
              >
                立即注册
              </el-button>
            </el-form-item>
          </el-form>
        </template>

        <!-- ===== 注册视图 ===== -->
        <template v-if="viewMode === 'register'">
          <div class="form-header">
            <h2 class="form-title">用户注册</h2>
            <p class="form-subtitle">REGISTER</p>
          </div>

          <!-- 身份选择 -->
          <div class="role-selector">
            <div
              class="role-option"
              :class="{ active: registerRole === 'resident' }"
              @click="registerRole = 'resident'"
            >
              <span class="role-icon">🏠</span>
              <span class="role-name">居民</span>
            </div>
            <div
              class="role-option"
              :class="{ active: registerRole === 'worker' }"
              @click="registerRole = 'worker'"
            >
              <span class="role-icon worker-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="20" height="20">
                  <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>
                </svg>
              </span>
              <span class="role-name">维修工</span>
            </div>
          </div>

          <el-form
            ref="registerFormRef"
            :model="registerForm"
            :rules="registerRules"
            class="register-form"
            label-width="80px"
          >
            <el-form-item label="姓名" prop="name">
              <el-input v-model="registerForm.name" placeholder="请输入真实姓名" />
            </el-form-item>
            <el-form-item label="用户名" prop="username">
              <el-input v-model="registerForm.username" placeholder="请设置登录用户名" />
            </el-form-item>
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="registerForm.phone" placeholder="请输入联系电话" />
            </el-form-item>

            <el-form-item v-if="registerRole === 'resident'" label="居住地址" prop="address">
              <el-input v-model="registerForm.address" placeholder="如: 1栋101室" />
            </el-form-item>
            <el-form-item v-if="registerRole === 'worker'" label="技能特长" prop="skill">
              <el-input v-model="registerForm.skill" placeholder="如: 水电维修、管道疏通" />
            </el-form-item>

            <el-form-item label="密码" prop="password">
              <el-input v-model="registerForm.password" type="password" show-password placeholder="请设置密码" />
            </el-form-item>
            <el-form-item label="确认密码" prop="confirmPwd">
              <el-input v-model="registerForm.confirmPwd" type="password" show-password placeholder="请再次输入密码" />
            </el-form-item>

            <el-form-item class="center-btn">
              <el-button
                type="primary"
                size="large"
                :loading="registerLoading"
                class="login-btn"
                @click="handleRegister"
              >
                {{ registerRole === 'resident' ? '立即注册' : '提交注册' }}
              </el-button>
            </el-form-item>

            <el-form-item class="center-btn">
              <el-button
                class="register-btn"
                size="large"
                @click="switchView('login')"
              >
                返回登录
              </el-button>
            </el-form-item>
          </el-form>
        </template>

      </div>
    </div>

    <!-- 忘记密码弹窗 -->
    <el-dialog v-model="resetVisible" title="重置密码" width="420px">
      <el-form label-width="80px">
        <el-form-item label="用户名">
          <el-input v-model="resetForm.username" placeholder="请输入注册时的用户名" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="resetForm.phone" placeholder="请输入注册时绑定的手机号" />
        </el-form-item>
        <el-form-item label="新密码">
          <el-input v-model="resetForm.newPassword" placeholder="留空则重置为123456" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="resetVisible = false">取消</el-button>
        <el-button type="primary" :loading="resetLoading" @click="handleResetPwd">确认重置</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.login-page {
  display: flex;
  min-height: 100vh;
  width: 100%;
  position: relative;

  &::before {
    content: '';
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background:
      linear-gradient(rgba(0, 210, 211, 0.03) 1px, transparent 1px),
      linear-gradient(90deg, rgba(0, 210, 211, 0.03) 1px, transparent 1px);
    background-size: 40px 40px;
    pointer-events: none;
    z-index: 0;
  }

  &::after {
    content: '';
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background:
      radial-gradient(ellipse 80% 50% at 20% 40%, rgba(0, 210, 211, 0.08) 0%, transparent 60%),
      radial-gradient(ellipse 60% 40% at 80% 60%, rgba(0, 100, 200, 0.06) 0%, transparent 60%);
    pointer-events: none;
    z-index: 0;
  }
}

.login-page > * {
  position: relative;
  z-index: 1;
}

/* ===== 左侧品牌区 ===== */
.login-left {
  flex: 1;
  background: linear-gradient(135deg, rgba(15, 32, 39, 0.85) 0%, rgba(32, 58, 67, 0.85) 50%, rgba(44, 83, 100, 0.85) 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40px 60px;
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    top: -30%;
    right: -20%;
    width: 600px;
    height: 600px;
    background: radial-gradient(circle, rgba(0, 210, 211, 0.06) 0%, transparent 70%);
    pointer-events: none;
  }

  &::after {
    content: '';
    position: absolute;
    bottom: -20%;
    left: -10%;
    width: 500px;
    height: 500px;
    background: radial-gradient(circle, rgba(44, 83, 100, 0.3) 0%, transparent 70%);
    pointer-events: none;
  }
}

.brand-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  align-self: flex-start;
  margin-bottom: 40px;
}

.logo-icon {
  width: 36px;
  height: 36px;
  background: #00D2D3;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;

  svg {
    width: 20px;
    height: 20px;
    stroke: #fff;
  }
}

.logo-text {
  font-size: 15px;
  color: #00D2D3;
  font-weight: 500;
  letter-spacing: 2px;
}

.worker-image-card {
  width: 500px;
  height: 450px;
  background: rgba(0, 210, 211, 0.08);
  border: 1px solid rgba(0, 210, 211, 0.15);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 60px;
  margin-bottom: 32px;
  overflow: hidden;
}

.worker-logo-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.brand-footer {
  margin-top: auto;
  text-align: center;
}

.footer-desc {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.4);
  margin-bottom: 6px;
}

.footer-slogan {
  font-size: 13px;
  color: #00D2D3;
  letter-spacing: 2px;
}

/* ===== 右侧表单区 ===== */
.login-right {
  flex: 1;
  background: linear-gradient(135deg, rgba(26, 42, 58, 0.85) 0%, rgba(36, 59, 74, 0.85) 50%, rgba(44, 83, 100, 0.85) 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px;
}

.login-card {
  width: 440px;
  background: #E8ECF1;
  border-radius: 16px;
  padding: 40px 36px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.form-header {
  margin-bottom: 24px;
}

.form-title {
  font-size: 24px;
  font-weight: 700;
  color: #1A1A2E;
  margin-bottom: 4px;
}

.form-subtitle {
  font-size: 11px;
  color: #00D2D3;
  letter-spacing: 3px;
  text-transform: uppercase;
}

.form-label {
  font-size: 14px;
  color: #333;
  margin-bottom: 8px;
  font-weight: 500;
}

/* ===== 登录表单 ===== */
.login-form {
  :deep(.el-input__wrapper) {
    background: #F5F7FA;
    border: 1px solid #E0E4E8;
    border-radius: 8px;
    box-shadow: none;
    padding: 4px 12px;
  }

  :deep(.el-input__wrapper:hover) {
    border-color: #00D2D3;
  }

  :deep(.el-input__wrapper.is-focus) {
    border-color: #00D2D3;
  }

  :deep(.el-input__inner) {
    color: #333;
    font-size: 14px;
  }

  :deep(.el-input__inner::placeholder) {
    color: #A0A8B4;
  }

  :deep(.el-input__prefix .el-icon) {
    color: #A0A8B4;
  }

  :deep(.el-form-item) {
    margin-bottom: 18px;
  }

  :deep(.el-checkbox__label) {
    color: #666;
    font-size: 13px;
  }

  :deep(.el-checkbox__input.is-checked .el-checkbox__inner) {
    background-color: #00D2D3;
    border-color: #00D2D3;
  }
}

/* ===== 注册表单 ===== */
.register-form {
  :deep(.el-form-item) {
    margin-bottom: 16px;
  }

  :deep(.el-form-item.center-btn) {
    display: flex;
    justify-content: center;

    .el-form-item__content {
      width: 100%;
      margin-left: 0 !important;
    }
  }

  :deep(.el-form-item__label) {
    color: #333;
    font-weight: 500;
    font-size: 14px;
    white-space: nowrap;
  }

  :deep(.el-input__wrapper) {
    background: #F5F7FA;
    border: 1px solid #E0E4E8;
    border-radius: 8px;
    box-shadow: none;
    padding: 4px 12px;
  }

  :deep(.el-input__wrapper:hover) {
    border-color: #00D2D3;
  }

  :deep(.el-input__wrapper.is-focus) {
    border-color: #00D2D3;
  }

  :deep(.el-input__inner) {
    color: #333;
    font-size: 14px;
  }

  :deep(.el-input__inner::placeholder) {
    color: #A0A8B4;
  }
}

/* ===== 身份选择器 ===== */
.role-selector {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
}

.role-option {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 16px;
  border: 2px solid #D0D5DD;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
  background: #fff;

  &:hover {
    border-color: #00D2D3;
  }

  &.active {
    border-color: #00D2D3;
    background: rgba(0, 210, 211, 0.08);
  }
}

.role-icon {
  font-size: 20px;
  display: flex;
  align-items: center;

  svg {
    stroke: #555;
  }
}

.worker-icon svg {
  stroke: #555;
}

.role-name {
  font-size: 15px;
  font-weight: 600;
  color: #333;
}

.login-role-selector {
  margin-bottom: 0;
}

.remember-row {
  display: flex;
  justify-content: flex-end;
  gap: 24px;
  margin-bottom: 8px;
}

.forgot-row {
  text-align: right;
  margin-bottom: 20px;
}

.register-btn {
  width: 100%;
  height: 44px;
  font-size: 15px;
  letter-spacing: 2px;
  background: #FFFFFF;
  color: #333;
  border: 1px solid #D0D5DD;
  border-radius: 8px;

  &:hover {
    background: #F5F7FA;
    border-color: #B0B5BD;
    color: #333;
  }
}

.login-btn {
  width: 100%;
  height: 44px;
  font-size: 15px;
  letter-spacing: 2px;
  border-radius: 8px;
  background: #1A2744;
  border-color: #1A2744;

  &:hover {
    background: #243352;
    border-color: #243352;
  }
}
</style>
