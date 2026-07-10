<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { registerResident } from '@/api/user'

const router = useRouter()
const formRef = ref(null)
const loading = ref(false)

const formData = reactive({
  name: '', username: '', phone: '', address: '', password: '', confirmPwd: ''
})

const validateConfirm = (rule, value, callback) => {
  if (value !== formData.password) callback(new Error('两次密码不一致'))
  else callback()
}

const rules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  phone: [{ required: true, message: '请输入手机号', trigger: 'blur' }],
  address: [{ required: true, message: '请输入居住地址', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  confirmPwd: [{ required: true, validator: validateConfirm, trigger: 'blur' }]
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    await registerResident({
      name: formData.name,
      username: formData.username,
      phone: formData.phone,
      address: formData.address,
      password: formData.password
    })
    ElMessage.success('注册成功,请登录')
    router.push('/login')
  } catch {
    // handled
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="register-page">
    <el-card class="register-card">
      <template #header>
        <div class="card-title">
          <span>居民注册</span>
          <el-link type="primary" @click="router.push('/login')">返回登录</el-link>
        </div>
      </template>
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="80px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="formData.name" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="用户名" prop="username">
          <el-input v-model="formData.username" placeholder="请设置登录用户名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="formData.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="居住地址" prop="address">
          <el-input v-model="formData.address" placeholder="如: 1栋101室" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="formData.password" type="password" show-password placeholder="请设置密码" />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPwd">
          <el-input v-model="formData.confirmPwd" type="password" show-password placeholder="请再次输入密码" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" class="submit-btn" @click="handleSubmit">
            立即注册
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<style scoped lang="scss">
.register-page {
  min-height: 100vh;
  background: #F1F5F9;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
}
.register-card {
  width: 500px;
}
.card-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 18px;
  font-weight: 600;
}
.submit-btn { width: 100%; }
</style>