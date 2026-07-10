<script setup>
import { ref, onMounted, computed } from 'vue'
import { listRepairs, cancelRepair } from '@/api/repair'
import { createEvaluation } from '@/api/evaluation'
import { ElMessageBox, ElMessage } from 'element-plus'
import { Clock, Document, Operation, CircleCheck, MoreFilled, Calendar } from '@element-plus/icons-vue'
import StarRating from '@/components/StarRating.vue'
import RepairDetailDialog from '@/views/resident/RepairDetailDialog.vue'

const loading = ref(false)
const rows = ref([])
const detailVisible = ref(false)
const detailId = ref(null)
const evalVisible = ref(false)
const evalRepairId = ref(null)
const evalScore = ref(5)
const evalComment = ref('')
const evalLoading = ref(false)

const statusMap = {
  pending: { label: '待处理', color: '#F59E0B', dot: '#F59E0B' },
  assigned: { label: '已派单', color: '#8B5CF6', dot: '#8B5CF6' },
  processing: { label: '处理中', color: '#3B82F6', dot: '#3B82F6' },
  completed: { label: '已完成', color: '#10B981', dot: '#10B981' },
  cancelled: { label: '已取消', color: '#94A3B8', dot: '#94A3B8' }
}

const stats = computed(() => {
  const list = rows.value
  return [
    { label: '待接单', value: list.filter(r => r.status === 'pending').length, icon: Clock, color: '#F59E0B', bg: '#FFF7ED', change: '+12%' },
    { label: '已派单', value: list.filter(r => r.status === 'assigned').length, icon: Document, color: '#8B5CF6', bg: '#F5F3FF', change: '0%' },
    { label: '处理中', value: list.filter(r => r.status === 'processing').length, icon: Operation, color: '#3B82F6', bg: '#EFF6FF', change: '+25%' },
    { label: '已完成', value: list.filter(r => r.status === 'completed').length, icon: CircleCheck, color: '#10B981', bg: '#ECFDF5', change: '+8%' }
  ]
})

const boards = computed(() => [
  {
    label: '待处理', en: 'To Do', color: '#F59E0B',
    list: rows.value.filter(r => ['pending', 'assigned'].includes(r.status))
  },
  {
    label: '进行中', en: 'On Progress', color: '#3B82F6',
    list: rows.value.filter(r => r.status === 'processing')
  },
  {
    label: '已完成', en: 'Done', color: '#10B981',
    list: rows.value.filter(r => ['completed', 'cancelled'].includes(r.status))
  }
])

async function fetchData() {
  if (!localStorage.getItem('community-repair-user')) return
  loading.value = true
  try {
    const res = await listRepairs({ pageSize: 100 })
    rows.value = res.data.rows || []
  } finally { loading.value = false }
}

async function handleCancel(id) {
  try {
    await ElMessageBox.confirm('确定要取消该工单吗?', '提示', { type: 'warning' })
    await cancelRepair(id)
    ElMessage.success('取消成功')
    fetchData()
  } catch { /* cancelled */ }
}

function showDetail(id) { detailId.value = id; detailVisible.value = true }

function showEval(id) { evalRepairId.value = id; evalScore.value = 5; evalComment.value = ''; evalVisible.value = true }

async function submitEval() {
  evalLoading.value = true
  try {
    await createEvaluation({ repairId: evalRepairId.value, score: evalScore.value, comment: evalComment.value })
    ElMessage.success('评价成功')
    evalVisible.value = false
    fetchData()
  } catch {} finally { evalLoading.value = false }
}

function hasEvaluated(row) {
  return row.hasEvaluation
}

onMounted(fetchData)
</script>

<template>
  <div class="dashboard">
    <div class="page-header">
      <div>
        <h2>仪表盘</h2>
        <p class="subtitle">查看您的工单统计与任务追踪</p>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-row">
      <el-card v-for="s in stats" :key="s.label" shadow="hover" class="stat-card">
        <div class="stat-top">
          <div class="stat-icon" :style="{ background: s.bg }">
            <el-icon :size="22" :style="{ color: s.color }"><component :is="s.icon" /></el-icon>
          </div>
          <span class="stat-change" :class="{ up: s.change.startsWith('+') && s.change !== '+0%', down: s.change === '0%' }">
            {{ s.change.startsWith('+') ? '↑' : '→' }} {{ s.change }}
          </span>
        </div>
        <div class="stat-value">{{ s.value }}</div>
        <div class="stat-label">{{ s.label }}</div>
      </el-card>
    </div>

    <!-- 看板列 -->
    <div class="board-container">
      <div v-for="board in boards" :key="board.label" class="board-column">
        <div class="board-header">
          <div class="board-title-wrap">
            <span class="board-bar" :style="{ background: board.color }"></span>
            <span class="board-title">{{ board.label }}</span>
            <span class="board-en">{{ board.en }}</span>
          </div>
          <el-tag :color="board.color" size="small" effect="plain" round>{{ board.list.length }}</el-tag>
        </div>
        <div class="board-list">
          <div v-for="item in board.list" :key="item.id" class="task-card" @click="showDetail(item.id)">
            <div class="task-top">
              <span class="task-title">{{ item.title }}</span>
              <el-icon class="task-more" @click.stop><MoreFilled /></el-icon>
            </div>
            <div class="task-status">
              <span class="status-dot" :style="{ background: statusMap[item.status]?.dot }"></span>
              <span :style="{ color: statusMap[item.status]?.color }">{{ statusMap[item.status]?.label }}</span>
            </div>
            <div class="task-date">
              <el-icon><Calendar /></el-icon>
              {{ item.createTime?.slice(0, 10) }}
            </div>
            <div v-if="item.status === 'completed'" class="task-eval-preview" @click.stop>
              <StarRating :model-value="item.evaluationScore || 0" />
            </div>
            <div class="task-actions" @click.stop>
              <el-button v-if="item.status === 'pending'" size="small" @click="handleCancel(item.id)">取消</el-button>
              <el-button v-if="item.status === 'processing'" size="small" type="primary" @click="showDetail(item.id)">查看</el-button>
              <el-button v-if="item.status === 'completed' && !item.hasEvaluation" size="small" type="primary" @click="showEval(item.id)">评价</el-button>
              <el-button v-if="item.status === 'completed' && item.hasEvaluation" size="small" disabled>已评价</el-button>
            </div>
          </div>
          <el-empty v-if="!board.list.length" description="暂无数据" :image-size="50" />
        </div>
      </div>
    </div>

    <RepairDetailDialog v-model:visible="detailVisible" :repair-id="detailId" @refresh="fetchData" />

    <el-dialog v-model="evalVisible" title="评价工单" width="420px">
      <div class="eval-form">
        <div class="eval-stars">
          <StarRating v-model="evalScore" :editable="true" :size="32" />
          <span class="eval-score-text">{{ evalScore }}分</span>
        </div>
        <el-input v-model="evalComment" type="textarea" :rows="3" placeholder="请输入评价内容(可选)" />
      </div>
      <template #footer>
        <el-button @click="evalVisible = false">取消</el-button>
        <el-button type="primary" :loading="evalLoading" @click="submitEval">提交评价</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.dashboard { padding: 4px; background: #F0F2F5; min-height: 100%; margin: -20px; padding: 20px; }
.page-header { margin-bottom: 24px; }
.page-header h2 { margin: 0; font-size: 22px; color: #1E293B; font-weight: 700; }
.subtitle { margin: 4px 0 0; font-size: 13px; color: #94A3B8; }

.stats-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
.stat-card { border-radius: 12px; :deep(.el-card__body) { padding: 20px; } }
.stat-top { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
.stat-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
.stat-change { font-size: 12px; font-weight: 600; &.up { color: #10B981; } &.down { color: #94A3B8; } }
.stat-value { font-size: 28px; font-weight: 700; color: #1E293B; margin-bottom: 2px; }
.stat-label { font-size: 13px; color: #64748B; }

.board-container { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
.board-column { background: #fff; border-radius: 12px; padding: 16px; min-height: 300px; }
.board-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.board-title-wrap { display: flex; align-items: center; gap: 8px; }
.board-bar { width: 4px; height: 18px; border-radius: 2px; }
.board-title { font-size: 15px; font-weight: 700; color: #1E293B; }
.board-en { font-size: 12px; color: #94A3B8; font-weight: 400; }

.board-list { display: flex; flex-direction: column; gap: 12px; }
.task-card {
  background: #fff; border: 1px solid #E2E8F0; border-radius: 10px; padding: 16px;
  cursor: pointer; transition: box-shadow 0.2s;
  &:hover { box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
}
.task-top { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px; }
.task-title { font-size: 14px; font-weight: 600; color: #1E293B; flex: 1; }
.task-more { color: #94A3B8; cursor: pointer; font-size: 16px; }
.task-status { display: flex; align-items: center; gap: 6px; margin-bottom: 8px; font-size: 13px; font-weight: 500; }
.status-dot { width: 8px; height: 8px; border-radius: 50%; }
.task-date { display: flex; align-items: center; gap: 4px; font-size: 12px; color: #94A3B8; margin-bottom: 12px; }
.task-eval-preview { margin-bottom: 8px; }
.task-actions { display: flex; gap: 8px; }
.task-actions .el-button { flex: 1; }

.eval-form { display: flex; flex-direction: column; gap: 16px; }
.eval-stars { display: flex; align-items: center; gap: 12px; }
.eval-score-text { font-size: 18px; font-weight: 600; color: #F59E0B; }
</style>
