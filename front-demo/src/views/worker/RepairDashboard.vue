<script setup>
import { ref, onMounted, computed } from 'vue'
import { listRepairs, updateRepairStatus } from '@/api/repair'
import { ElMessageBox, ElMessage } from 'element-plus'
import StatusTag from '@/components/StatusTag.vue'
import { Clock, Loading, CircleCheck, User } from '@element-plus/icons-vue'

const loading = ref(false)
const rows = ref([])
const resultVisible = ref(false)
const currentRepairId = ref(null)
const repairResult = ref('')
const resultLoading = ref(false)

const pendingList = computed(() => rows.value.filter(r => r.status === 'assigned'))
const processingList = computed(() => rows.value.filter(r => r.status === 'processing'))
const completedList = computed(() => rows.value.filter(r => r.status === 'completed'))

const stats = computed(() => ({
  pending: pendingList.value.length,
  processing: processingList.value.length,
  completed: completedList.value.length
}))

async function fetchData() {
  loading.value = true
  try {
    const res = await listRepairs({ pageSize: 100 })
    rows.value = res.data.rows || []
  } finally { loading.value = false }
}

async function startProcessing(id) {
  try {
    await ElMessageBox.confirm('确认开始维修该工单?', '提示', { type: 'info' })
    await updateRepairStatus({ repairId: id, status: 'processing' })
    ElMessage.success('已开始维修')
    fetchData()
  } catch { /* cancelled */ }
}

function showResultDialog(id) { currentRepairId.value = id; repairResult.value = ''; resultVisible.value = true }

async function submitResult() {
  if (!repairResult.value) { ElMessage.warning('请填写维修结果'); return }
  resultLoading.value = true
  try {
    await updateRepairStatus({ repairId: currentRepairId.value, status: 'completed', result: repairResult.value })
    ElMessage.success('工单已完成')
    resultVisible.value = false
    fetchData()
  } catch {} finally { resultLoading.value = false }
}

onMounted(fetchData)
</script>

<template>
  <div v-loading="loading">
    <!-- 页面标题 -->
    <div class="page-header">
      <div>
        <h2>工单看板</h2>
        <p class="header-sub">管理和跟踪所有维修工单进度</p>
      </div>

    </div>

    <!-- 统计卡片 -->
    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-header">
          <span class="stat-label">待处理工单</span>
          <div class="stat-icon orange"><el-icon><Clock /></el-icon></div>
        </div>
        <div class="stat-value">{{ stats.pending }}</div>
        <div class="stat-trend"><span class="trend-up">较昨日 +1</span></div>
        <div class="stat-bar"><div class="stat-progress orange" :style="{width: Math.min(stats.pending * 10, 100) + '%'}"></div></div>
      </div>

      <div class="stat-card">
        <div class="stat-header">
          <span class="stat-label">处理中工单</span>
          <div class="stat-icon purple"><el-icon><Loading /></el-icon></div>
        </div>
        <div class="stat-value">{{ stats.processing }}</div>
        <div class="stat-trend"><span class="trend-flat">较昨日持平</span></div>
        <div class="stat-bar"><div class="stat-progress purple" :style="{width: Math.min(stats.processing * 10, 100) + '%'}"></div></div>
      </div>

      <div class="stat-card">
        <div class="stat-header">
          <span class="stat-label">已完成工单</span>
          <div class="stat-icon green"><el-icon><CircleCheck /></el-icon></div>
        </div>
        <div class="stat-value">{{ stats.completed }}</div>
        <div class="stat-trend"><span class="trend-up">较昨日 +2</span></div>
        <div class="stat-bar"><div class="stat-progress green" :style="{width: Math.min(stats.completed * 10, 100) + '%'}"></div></div>
      </div>
    </div>

    <!-- 看板 -->
    <div class="board-container">
      <!-- 待处理 -->
      <div class="board-column">
        <div class="board-title">
          <span class="dot orange"></span>
          <span>待处理</span>
          <el-tag size="small" type="info" effect="light" round>{{ stats.pending }}</el-tag>
        </div>
        <div class="board-cards">
          <div v-for="item in pendingList" :key="item.id" class="task-card">
            <div class="card-top">
              <StatusTag :status="item.status" />
              <span class="card-id">WO-{{ String(item.id).padStart(6,'0') }}</span>
              <el-tag v-if="item.priority === 'urgent'" type="danger" size="small" effect="dark" style="margin-left:auto">紧急</el-tag>
            </div>
            <div class="card-title">{{ item.title }}</div>
            <div class="card-desc">{{ item.description }}</div>
            <div class="card-user">
              <el-avatar :size="28" :src="item.userAvatar"><el-icon><User /></el-icon></el-avatar>
              <div class="user-info">
                <div class="user-name">{{ item.userName || '未知居民' }}</div>
                <div class="user-phone">{{ item.contactPhone || '-' }}</div>
              </div>
            </div>
            <div class="card-bottom">
              <span class="card-time">{{ item.createTime }}</span>
              <el-button size="small" type="primary" @click="startProcessing(item.id)">开始维修</el-button>
            </div>
          </div>
          <el-empty v-if="!pendingList.length" description="暂无待处理工单" :image-size="60" />
        </div>
      </div>

      <!-- 进行中 -->
      <div class="board-column">
        <div class="board-title">
          <span class="dot purple"></span>
          <span>进行中</span>
          <el-tag size="small" type="info" effect="light" round>{{ stats.processing }}</el-tag>
        </div>
        <div class="board-cards">
          <div v-for="item in processingList" :key="item.id" class="task-card">
            <div class="card-top">
              <StatusTag :status="item.status" />
              <span class="card-id">WO-{{ String(item.id).padStart(6,'0') }}</span>
              <el-tag v-if="item.priority === 'urgent'" type="danger" size="small" effect="dark" style="margin-left:auto">紧急</el-tag>
            </div>
            <div class="card-title">{{ item.title }}</div>
            <div class="card-desc">{{ item.description }}</div>
            <div class="card-progress">
              <div class="progress-label">维修进度</div>
              <el-progress :percentage="60" :stroke-width="6" color="#8B5CF6" :show-text="false" />
              <span class="progress-text">60%</span>
            </div>
            <div class="card-user">
              <el-avatar :size="28" :src="item.userAvatar"><el-icon><User /></el-icon></el-avatar>
              <div class="user-info">
                <div class="user-name">{{ item.userName || '未知居民' }}</div>
                <div class="user-phone">{{ item.contactPhone || '-' }}</div>
              </div>
            </div>
            <div class="card-bottom">
              <span class="card-time">{{ item.createTime }}</span>
              <el-button size="small" type="success" @click="showResultDialog(item.id)">完成维修</el-button>
            </div>
          </div>
          <el-empty v-if="!processingList.length" description="暂无进行中工单" :image-size="60" />
        </div>
      </div>

      <!-- 已完成 -->
      <div class="board-column">
        <div class="board-title">
          <span class="dot green"></span>
          <span>已完成</span>
          <el-tag size="small" type="info" effect="light" round>{{ stats.completed }}</el-tag>
        </div>
        <div class="board-cards">
          <div v-for="item in completedList" :key="item.id" class="task-card">
            <div class="card-top">
              <StatusTag :status="item.status" />
              <span class="card-id">WO-{{ String(item.id).padStart(6,'0') }}</span>
              <el-tag v-if="item.priority === 'urgent'" type="danger" size="small" effect="dark" style="margin-left:auto">紧急</el-tag>
            </div>
            <div class="card-title">{{ item.title }}</div>
            <div class="card-desc">{{ item.description }}</div>
            <div class="card-user">
              <el-avatar :size="28" :src="item.userAvatar"><el-icon><User /></el-icon></el-avatar>
              <div class="user-info">
                <div class="user-name">{{ item.userName || '未知居民' }}</div>
                <div class="user-phone">{{ item.contactPhone || '-' }}</div>
              </div>
            </div>
            <div class="card-bottom">
              <span class="card-time">{{ item.createTime }}</span>
            </div>
          </div>
          <el-empty v-if="!completedList.length" description="暂无已完成工单" :image-size="60" />
        </div>
      </div>
    </div>

    <!-- 填写结果弹窗 -->
    <el-dialog v-model="resultVisible" title="填写维修结果" width="450px">
      <el-input v-model="repairResult" type="textarea" :rows="4" placeholder="请填写维修结果说明" />
      <template #footer>
        <el-button @click="resultVisible = false">取消</el-button>
        <el-button type="primary" :loading="resultLoading" @click="submitResult">提交完成</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  h2 { margin: 0; font-size: 20px; color: #1E293B; }
  .header-sub { margin: 4px 0 0; font-size: 13px; color: #94A3B8; }
  .header-actions { display: flex; gap: 8px; }
}

/* 统计卡片 */
.stats-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}
.stat-card {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}
.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.stat-label {
  font-size: 13px;
  color: #64748B;
}
.stat-icon {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  &.orange { background: #FFF7ED; color: #F97316; }
  &.purple { background: #F5F3FF; color: #8B5CF6; }
  &.green { background: #ECFDF5; color: #10B981; }
}
.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #1E293B;
  margin-bottom: 4px;
}
.stat-trend {
  font-size: 12px;
  margin-bottom: 12px;
  .trend-up { color: #EF4444; }
  .trend-flat { color: #94A3B8; }
}
.stat-bar {
  height: 4px;
  background: #F1F5F9;
  border-radius: 2px;
  overflow: hidden;
}
.stat-progress {
  height: 100%;
  border-radius: 2px;
  transition: width 0.3s;
  &.orange { background: #F97316; }
  &.purple { background: #8B5CF6; }
  &.green { background: #10B981; }
}

/* 看板 */
.board-container {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
.board-column {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.board-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 600;
  color: #1E293B;
  margin-bottom: 4px;
  .dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    &.orange { background: #F97316; }
    &.purple { background: #8B5CF6; }
    &.green { background: #10B981; }
  }
}
.board-cards {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

/* 任务卡片 */
.task-card {
  background: #fff;
  border-radius: 10px;
  padding: 14px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
  transition: box-shadow 0.2s;
  &:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
}
.card-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.card-id {
  font-size: 12px;
  color: #94A3B8;
}
.card-title {
  font-size: 14px;
  font-weight: 600;
  color: #1E293B;
  margin-bottom: 6px;
}
.card-desc {
  font-size: 12px;
  color: #64748B;
  line-height: 1.5;
  margin-bottom: 10px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.card-progress {
  margin-bottom: 10px;
  .progress-label {
    font-size: 12px;
    color: #94A3B8;
    margin-bottom: 4px;
    display: flex;
    justify-content: space-between;
  }
  .progress-text { font-size: 12px; color: #8B5CF6; }
  :deep(.el-progress-bar__outer) { background-color: #F3F0FF; }
}
.card-user {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
  .user-info {
    .user-name { font-size: 12px; color: #334155; font-weight: 500; }
    .user-phone { font-size: 11px; color: #94A3B8; }
  }
}
.card-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.card-time {
  font-size: 12px;
  color: #94A3B8;
}
</style>
