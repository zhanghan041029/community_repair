<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { updateProfile, changePassword } from '@/api/user'
import { ElMessage } from 'element-plus'
import AvatarUpload from '@/components/AvatarUpload.vue'

const router = useRouter()
const userStore = useUserStore()
const formRef = ref(null)
const pwdFormRef = ref(null)
const loading = ref(false)
const editing = ref(false)
const pwdVisible = ref(false)
const pwdLoading = ref(false)

const formData = reactive({
  phone: '',
  address: '',
  skill: ''
})

const pwdForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPwd: ''
})

const user = computed(() => userStore.userInfo || {})

const roleLabel = computed(() => ({ resident: '居民', worker: '维修工', admin: '管理员' }[user.value.role] || user.value.role))
const roleIcon = computed(() => ({ resident: '', worker: '🔧', admin: '⚙️' }[user.value.role] || '👤'))

function startEdit() {
  formData.phone = user.value.phone || ''
  formData.address = user.value.address || ''
  formData.skill = user.value.skill || ''
  editing.value = true
}

function cancelEdit() { editing.value = false }

const validateConfirm = (rule, value, callback) => {
  if (value !== pwdForm.newPassword) callback(new Error('两次密码不一致'))
  else callback()
}

const pwdRules = {
  oldPassword: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '新密码长度不能少于6位', trigger: 'blur' }
  ],
  confirmPwd: [{ validator: validateConfirm, trigger: 'blur' }]
}

async function handleSave() {
  loading.value = true
  try {
    const data = {}
    if (formData.phone) data.phone = formData.phone
    if (formData.address !== undefined) data.address = formData.address
    if (formData.skill !== undefined) data.skill = formData.skill
    await updateProfile(data)
    ElMessage.success('修改成功')
    await userStore.fetchCurrentUser()
    editing.value = false
  } catch {} finally { loading.value = false }
}

async function handlePwdSave() {
  const valid = await pwdFormRef.value?.validate().catch(() => false)
  if (!valid) return
  pwdLoading.value = true
  try {
    await changePassword({ oldPassword: pwdForm.oldPassword, newPassword: pwdForm.newPassword })
    ElMessage.success('密码修改成功，请重新登录')
    pwdVisible.value = false
    pwdForm.oldPassword = ''
    pwdForm.newPassword = ''
    pwdForm.confirmPwd = ''
    userStore.logout()
    router.push('/login')
  } catch {} finally { pwdLoading.value = false }
}
</script>

<template>
  <div class="profile">
    <!-- 顶部个人信息卡片 -->
    <div class="profile-header">
      <div class="header-bg"></div>
      <div class="header-content">
        <div class="avatar-wrapper">
          <AvatarUpload v-model="user.avatar" :size="90" />
        </div>
        <div class="user-info">
          <h2 class="user-name">{{ user.name || '未知' }}</h2>
          <span class="user-role">
            <span class="role-emoji">{{ roleIcon }}</span>
            {{ roleLabel }}
          </span>
        </div>
      </div>
    </div>

    <!-- 信息详情卡片 -->
    <div class="info-card">
      <div v-if="!editing" class="info-grid">
        <div class="info-item">
          <div class="info-label">
            <span class="info-icon">👤</span>
            <span>姓名</span>
          </div>
          <div class="info-value">{{ user.name || '-' }}</div>
        </div>
        <div class="info-item">
          <div class="info-label">
            <span class="info-icon"></span>
            <span>用户名</span>
          </div>
          <div class="info-value">{{ user.username || '-' }}</div>
        </div>
        <div class="info-item">
          <div class="info-label">
            <span class="info-icon"></span>
            <span>手机号</span>
          </div>
          <div class="info-value">{{ user.phone || '-' }}</div>
        </div>
        <div class="info-item">
          <div class="info-label">
            <span class="info-icon">🏷️</span>
            <span>角色</span>
          </div>
          <div class="info-value">
            <el-tag size="small" :type="{ resident: 'success', worker: 'warning', admin: 'danger' }[user.role] || 'info'">
              {{ roleLabel }}
            </el-tag>
          </div>
        </div>
        <div v-if="user.address" class="info-item">
          <div class="info-label">
            <span class="info-icon"></span>
            <span>地址</span>
          </div>
          <div class="info-value">{{ user.address }}</div>
        </div>
        <div v-if="user.skill" class="info-item">
          <div class="info-label">
            <span class="info-icon">️</span>
            <span>技能</span>
          </div>
          <div class="info-value">{{ user.skill }}</div>
        </div>
      </div>

      <el-form v-else ref="formRef" :model="formData" label-width="80px" class="edit-form">
        <el-form-item label="手机号"><el-input v-model="formData.phone" placeholder="请输入手机号" /></el-form-item>
        <el-form-item v-if="user.role !== 'admin'" label="地址">
          <el-input v-model="formData.address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item v-if="user.role === 'worker'" label="技能">
          <el-input v-model="formData.skill" placeholder="请输入技能特长" />
        </el-form-item>
      </el-form>

      <div class="profile-actions">
        <el-button v-if="!editing" type="primary" @click="startEdit">
          <el-icon><Edit /></el-icon> 编辑资料
        </el-button>
        <el-button v-if="!editing" type="warning" plain @click="pwdVisible = true">
          <el-icon><Lock /></el-icon> 修改密码
        </el-button>
        <template v-else>
          <el-button type="primary" :loading="loading" @click="handleSave">保存</el-button>
          <el-button @click="cancelEdit">取消</el-button>
        </template>
      </div>
    </div>

    <!-- 修改密码弹窗 -->
    <el-dialog v-model="pwdVisible" title="修改密码" width="420px" destroy-on-close>
      <el-form ref="pwdFormRef" :model="pwdForm" :rules="pwdRules" label-width="80px">
        <el-form-item label="原密码" prop="oldPassword">
          <el-input v-model="pwdForm.oldPassword" type="password" show-password placeholder="请输入原密码" />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="pwdForm.newPassword" type="password" show-password placeholder="请输入新密码（至少6位）" />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPwd">
          <el-input v-model="pwdForm.confirmPwd" type="password" show-password placeholder="请再次输入新密码" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="pwdVisible = false">取消</el-button>
        <el-button type="primary" :loading="pwdLoading" @click="handlePwdSave">确认修改</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.profile {
  max-width: 700px;
  margin: 0 auto;
}

/* 顶部个人信息卡片 */
.profile-header {
  position: relative;
  border-radius: 16px;
  overflow: hidden;
  margin-bottom: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.header-bg {
  height: 120px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.header-content {
  display: flex;
  align-items: flex-end;
  padding: 0 24px 20px;
  gap: 20px;
  margin-top: -45px;
}

.avatar-wrapper {
  flex-shrink: 0;
  border-radius: 50%;
  border: 4px solid #fff;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  overflow: hidden;
  background: #fff;
}

.user-info {
  padding-bottom: 8px;
}

.user-name {
  margin: 0 0 6px;
  font-size: 22px;
  font-weight: 700;
  color: #1E293B;
}

.user-role {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 3px 12px;
  background: #F1F5F9;
  border-radius: 20px;
  font-size: 13px;
  color: #64748B;
}

.role-emoji {
  font-size: 14px;
}

/* 信息详情卡片 */
.info-card {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0;
}

.info-item {
  display: flex;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #F1F5F9;
}

.info-item:nth-child(odd) {
  border-right: 1px solid #F1F5F9;
}

.info-label {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 90px;
  font-size: 14px;
  color: #94A3B8;
}

.info-icon {
  font-size: 16px;
}

.info-value {
  font-size: 15px;
  color: #1E293B;
  font-weight: 500;
}

/* 编辑表单 */
.edit-form {
  padding: 8px 0;
}

/* 操作按钮 */
.profile-actions {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #F1F5F9;
  display: flex;
  gap: 12px;
}
</style>
