<script setup>
import { ref, onMounted } from 'vue'
import { listAnnouncements } from '@/api/announcement'
import { Bell } from '@element-plus/icons-vue'

const loading = ref(false)
const announcements = ref([])
const detailVisible = ref(false)
const detailData = ref(null)

async function fetchData() {
  loading.value = true
  try {
    const res = await listAnnouncements()
    announcements.value = res.data || []
  } catch {} finally { loading.value = false }
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
      <h2>社区公告</h2>
    </div>

    <div class="card" v-loading="loading">
      <el-empty v-if="!loading && announcements.length === 0" description="暂无公告" />
      <div v-else class="announcement-list">
        <div
          v-for="item in announcements"
          :key="item.id"
          class="announcement-item"
          @click="showDetail(item)"
        >
          <div class="item-icon">
            <el-icon :size="20"><Bell /></el-icon>
          </div>
          <div class="item-info">
            <div class="item-title">{{ item.title }}</div>
            <div class="item-meta">
              <span>{{ item.publisherName }}</span>
              <span class="separator">|</span>
              <span>{{ formatTime(item.createTime) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

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
  gap: 12px;
  padding: 16px;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: box-shadow 0.2s;
  &:hover {
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    background: #F8FAFC;
  }
  &:last-child { margin-bottom: 0; }
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
}

.item-meta {
  font-size: 12px;
  color: #94A3B8;
  margin-top: 4px;
  .separator { margin: 0 8px; }
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
