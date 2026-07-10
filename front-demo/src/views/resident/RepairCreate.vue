<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { createRepair, uploadRepairImage } from '@/api/repair'
import { ElMessage } from 'element-plus'
import { Plus, Delete } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()
const formRef = ref(null)
const loading = ref(false)

const formData = reactive({
  title: '', description: '', address: '', contactPhone: '', image: '', priority: 'normal'
})
const imageList = ref([])

onMounted(async () => {
  if (!userStore.userInfo) {
    await userStore.fetchCurrentUser()
  }
  const info = userStore.userInfo
  if (info) {
    formData.address = info.address || ''
    formData.contactPhone = info.phone || ''
  }
})

const rules = {
  title: [{ required: true, message: '请输入报修标题', trigger: 'blur' }],
  description: [{ required: true, message: '请输入故障描述', trigger: 'blur' }],
  address: [{ required: true, message: '请输入维修地址', trigger: 'blur' }],
  contactPhone: [{ required: true, message: '请输入联系电话', trigger: 'blur' }]
}

async function handleImageUpload(options) {
  try {
    const res = await uploadRepairImage(options.file)
    formData.image = res.data.url
    options.onSuccess(res)
  } catch {
    ElMessage.error('图片上传失败')
    options.onError(new Error('上传失败'))
  }
}

function handleRemoveImage() {
  formData.image = ''
  imageList.value = []
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    await createRepair({ ...formData })
    ElMessage.success('报修提交成功')
    router.push('/dashboard')
  } catch {
    // handled
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="repair-create">
    <el-card>
      <template #header><h2>提交报修</h2></template>
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px" class="repair-form">
        <el-form-item label="报修标题" prop="title">
          <el-input v-model="formData.title" placeholder="如: 厨房水龙头漏水" />
        </el-form-item>
        <el-form-item label="紧急程度">
          <el-radio-group v-model="formData.priority">
            <el-radio value="normal">普通</el-radio>
            <el-radio value="urgent">紧急</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="故障描述" prop="description">
          <el-input v-model="formData.description" type="textarea" :rows="4" placeholder="请详细描述故障情况" />
        </el-form-item>
        <el-form-item label="现场照片">
          <template v-if="formData.image">
            <div class="image-preview">
              <el-image :src="'http://localhost:8080/api' + formData.image" fit="cover" style="width:200px;height:150px;border-radius:8px;" />
              <el-button size="small" type="danger" :icon="Delete" circle style="position:absolute;top:-8px;right:-8px;" @click="handleRemoveImage" />
            </div>
          </template>
          <el-upload
            v-else
            :http-request="handleImageUpload"
            :show-file-list="false"
            accept="image/*"
            :before-upload="(f) => { if (!f.type.startsWith('image/')) { ElMessage.warning('请上传图片文件'); return false; } return true; }"
          >
            <el-button :icon="Plus">选择现场照片（选填）</el-button>
          </el-upload>
        </el-form-item>
        <el-form-item label="维修地址" prop="address">
          <el-input v-model="formData.address" placeholder="如: 1栋101室" />
        </el-form-item>
        <el-form-item label="联系电话" prop="contactPhone">
          <el-input v-model="formData.contactPhone" placeholder="方便维修师傅联系的电话" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="handleSubmit">提交报修</el-button>
          <el-button @click="router.back()">返回</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<style scoped>
.repair-create { max-width: 700px; }
h2 { margin: 0; font-size: 20px; color: #1E293B; }
.repair-form { margin-top: 8px; }
.image-preview { position: relative; display: inline-block; }
</style>