<script setup>
import { ref, onMounted } from 'vue'
import { listAnnouncements, createAnnouncement, deleteAnnouncement } from '@/api/announcement'
import { ElMessageBox, ElMessage } from 'element-plus'
import { Plus, Delete, Bell } from '@element-plus/icons-vue'

const loading = ref(false)
const announcements = ref([])
const createVisible = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)
const creating = ref(false)

const form = ref({
  title: '',
  content: ''
})

async function fetchData() {
  loading.value = true
  try {
    const res = await listAnnouncements()
    announcements.value = res.data || []
  } catch {} finally { loading.value = false }
}

function openCreate() {
  form.value = { title: '', content: '' }
  createVisible.value = true
}

async function handleCreate() {
  if (!form.value.title.trim()) { ElMessage.warning('请输入公告标题'); return }
  if (!form.value.content.trim()) { ElMessage.warning('请输入公告内容'); return }
  creating.value = true
  try {
    await createAnnouncement(form.value)
    ElMessage.success('公告发布成功，已通知所有居民和维修工')
    createVisible.value = false
    fetchData()
  } catch {} finally { creating.value = false }
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm('确定删除该公告吗？', '提示', { type: 'warning' })
  } catch { return }
  try {
    await deleteAnnouncement(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch {}
}

function showDetail(row) {
  detailData.value = row
  detailVisible.value = true
}

function formatTime(time) {
  if (!time) return '-'
  return time.replace('T', ' ').substring(0, 19)
}

onMounted(() => fetchData())
</script>

<template>
  <div class="announcement-container">
    <div class="page-header">
      <h2>公告管理</h2>
      <el-button type="primary" :icon="Plus" @click="openCreate">发布公告</el-button>
    </div>

    <div class="card" v-loading="loading">
      <el-empty v-if="!loading && announcements.length === 0" description="暂无公告" />
      <div v-else class="announcement-list">
        <div
          v-for="item in announcements"
          :key="item.id"
          class="announcement-item"
        >
          <div class="item-left">
            <div class="item-icon">
              <el-icon :size="20"><Bell /></el-icon>
            </div>
            <div class="item-info">
              <div class="item-title" @click="showDetail(item)">{{ item.title }}</div>
              <div class="item-meta">
                <span>发布者：{{ item.publisherName }}</span>
                <span class="separator">|</span>
                <span>{{ formatTime(item.createTime) }}</span>
              </div>
            </div>
          </div>
          <div class="item-actions">
            <el-button link type="primary" @click="showDetail(item)">查看</el-button>
            <el-button link type="danger" :icon="Delete" @click="handleDelete(item)">删除</el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 发布公告弹窗 -->
    <el-dialog v-model="createVisible" title="发布公告" width="520px" :close-on-click-modal="false">
      <el-form :model="form" label-width="80px">
        <el-form-item label="公告标题" required>
          <el-input v-model="form.title" placeholder="请输入公告标题" maxlength="100" show-word-limit />
        </el-form-item>
        <el-form-item label="公告内容" required>
          <el-input
            v-model="form.content"
            type="textarea"
            :rows="6"
            placeholder="请输入公告内容"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createVisible = false">取消</el-button>
        <el-button type="primary" :loading="creating" @click="handleCreate">发布</el-button>
      </template>
    </el-dialog>

    <!-- 公告详情弹窗 -->
    <el-dialog v-model="detailVisible" title="公告详情" width="520px">
      <template v-if="detailData">
        <div class="detail-title">{{ detailData.title }}</div>
        <div class="detail-meta">
          <span>发布者：{{ detailData.publisherName }}</span>
          <span>发布时间：{{ formatTime(detailData.createTime) }}</span>
        </div>
        <div class="detail-content">{{ detailData.content }}</div>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.announcement-container {
  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    h2 {
      font-size: 20px;
      font-weight: 600;
      color: #1E293B;
    }
  }
  .card {
    background: #fff;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.06);
    min-height: 300px;
  }
}

.announcement-list {
  display: flex;
  flex-direction: column;
}

.announcement-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  margin-bottom: 12px;
  transition: box-shadow 0.2s;
  &:hover {
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  }
  &:last-child { margin-bottom: 0; }
}

.item-left {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  min-width: 0;
}

.item-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background: #EFF6FF;
  color: #3B82F6;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.item-info {
  flex: 1;
  min-width: 0;
}

.item-title {
  font-size: 15px;
  font-weight: 600;
  color: #1E293B;
  cursor: pointer;
  &:hover { color: #3B82F6; }
}

.item-meta {
  font-size: 12px;
  color: #94A3B8;
  margin-top: 4px;
  .separator { margin: 0 8px; }
}

.item-actions {
  flex-shrink: 0;
  margin-left: 16px;
}

.detail-title {
  font-size: 18px;
  font-weight: 600;
  color: #1E293B;
  margin-bottom: 8px;
}

.detail-meta {
  font-size: 13px;
  color: #94A3B8;
  display: flex;
  gap: 16px;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 1px solid #E2E8F0;
}

.detail-content {
  font-size: 14px;
  color: #475569;
  line-height: 1.8;
  white-space: pre-wrap;
}
</style>
