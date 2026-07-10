<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import { Plus } from '@element-plus/icons-vue'

const props = defineProps({
  modelValue: { type: String, default: '' },
  size: { type: Number, default: 80 }
})
const emit = defineEmits(['update:modelValue'])
const userStore = useUserStore()
const uploading = ref(false)
const inputRef = ref(null)

const validTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']

function handleClick() {
  inputRef.value?.click()
}

async function handleChange(e) {
  const file = e.target.files?.[0]
  if (!file) return

  if (!validTypes.includes(file.type)) {
    ElMessage.error('仅支持 jpg、png、gif、webp 格式')
    e.target.value = ''
    return
  }
  if (file.size > 2 * 1024 * 1024) {
    ElMessage.error('文件大小不能超过 2MB')
    e.target.value = ''
    return
  }

  uploading.value = true
  try {
    console.log('=== 头像上传开始 ===')
    console.log('token:', userStore.token?.substring(0, 20) + '...')
    console.log('file:', file.name, file.type, file.size)

    const result = await new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest()
      xhr.open('POST', '/api/users/avatar', true)
      xhr.setRequestHeader('Authorization', `Bearer ${userStore.token}`)
      xhr.onload = function () {
        console.log('XHR status:', xhr.status)
        console.log('XHR response:', xhr.responseText)
        if (xhr.status >= 200 && xhr.status < 300) {
          try {
            resolve(JSON.parse(xhr.responseText))
          } catch {
            reject(new Error('响应解析失败: ' + xhr.responseText))
          }
        } else {
          reject(new Error('上传失败，状态码: ' + xhr.status))
        }
      }
      xhr.onerror = function () {
        console.error('XHR onerror fired')
        reject(new Error('网络错误（可能是CORS跨域问题）'))
      }

      const formData = new FormData()
      formData.append('file', file)
      console.log('发送 FormData...')
      xhr.send(formData)
    })

    if (result.code === 1) {
      emit('update:modelValue', result.data.avatarUrl)
      await userStore.fetchCurrentUser()
      ElMessage.success('头像上传成功')
    } else {
      ElMessage.error(result.msg || '上传失败')
    }
  } catch (err) {
    ElMessage.error(err.message || '上传失败')
  } finally {
    uploading.value = false
    e.target.value = ''
  }
}
</script>

<template>
  <div class="avatar-upload" @click="handleClick">
    <el-avatar :size="size" :src="modelValue" v-loading="uploading">
      <el-icon :size="size * 0.4"><Plus /></el-icon>
    </el-avatar>
    <input
      ref="inputRef"
      type="file"
      accept="image/jpeg,image/png,image/gif,image/webp"
      style="display: none"
      @change="handleChange"
    />
  </div>
</template>

<style scoped>
.avatar-upload {
  display: inline-block;
  cursor: pointer;
}
.avatar-upload :deep(.el-avatar) {
  border: 2px dashed #CBD5E1;
}
.avatar-upload :deep(.el-avatar):hover {
  border-color: #3B82F6;
}
</style>
