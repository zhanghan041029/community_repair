<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { listRepairs, assignRepair, getRepairDetail } from '@/api/repair'
import { listWorkers } from '@/api/worker'
import { ElMessageBox, ElMessage } from 'element-plus'
import StatusTag from '@/components/StatusTag.vue'

const loading = ref(false)
const rows = ref([])
const total = ref(0)
const query = reactive({
  page: 1, pageSize: 10,
  status: '', residentName: '', workerName: '',
  beginDate: '', endDate: ''
})
const assignVisible = ref(false)
const assignRepairId = ref(null)
const assignWorkerId = ref(null)
const currentAssignOrder = ref(null)
const workers = ref([])
const assignLoading = ref(false)

// 批量派单
const selectedRows = ref([])
const batchAssignVisible = ref(false)
const batchAssignWorkerId = ref(null)
const batchAssignLoading = ref(false)
const batchWorkers = ref([])

const detailVisible = ref(false)
const detailData = ref(null)
const detailLoading = ref(false)

const statusOptions = [
  { label: '全部', value: '' }, { label: '待派单', value: 'pending' },
  { label: '已派单', value: 'assigned' }, { label: '处理中', value: 'processing' },
  { label: '已完成', value: 'completed' }, { label: '已取消', value: 'cancelled' }
]

// 判断工单是否超时（超过3天未派单）
const isOverdue = (order) => {
  if (order.status !== 'pending') return false
  if (order.pendingDays != null) return order.pendingDays > 3
  // 兜底：前端直接根据 createTime 计算
  if (order.createTime) {
    const diff = Date.now() - new Date(order.createTime).getTime()
    return diff > 3 * 24 * 60 * 60 * 1000
  }
  return false
}

// 获取行样式
const getRowClass = ({ row }) => {
  return isOverdue(row) ? 'overdue-row' : ''
}

// 待派单优先排序（客户端排序作为兜底）
const sortedRows = computed(() => {
  return [...rows.value].sort((a, b) => {
    if (a.status === 'pending' && b.status !== 'pending') return -1
    if (a.status !== 'pending' && b.status === 'pending') return 1
    if (a.priority === 'urgent' && b.priority !== 'urgent') return -1
    if (a.priority !== 'urgent' && b.priority === 'urgent') return 1
    return 0
  })
})

async function fetchData() {
  loading.value = true
  try {
    const res = await listRepairs({
      page: query.page, pageSize: query.pageSize,
      status: query.status || undefined,
      residentName: query.residentName || undefined,
      workerName: query.workerName || undefined,
      startTime: query.beginDate || undefined,
      endTime: query.endDate || undefined
    })
    rows.value = res.data.rows || []
    total.value = res.data.total || 0
  } finally { loading.value = false }
}

function handleReset() {
  query.status = ''
  query.residentName = ''
  query.workerName = ''
  query.beginDate = ''
  query.endDate = ''
  query.page = 1
  fetchData()
}

async function showAssignDialog(repairId) {
  assignRepairId.value = repairId
  assignWorkerId.value = null
  currentAssignOrder.value = rows.value.find(r => r.id === repairId) || null
  const res = await listWorkers({ status: 'active', pageSize: 200 })
  workers.value = res.data.rows || []
  assignVisible.value = true
}

async function handleAssign() {
  if (!assignWorkerId.value) { ElMessage.warning('请选择维修工'); return }

  const selectedWorker = workers.value.find(w => w.id === assignWorkerId.value)
  const orderTitle = currentAssignOrder.value?.title || ''

  try {
    await ElMessageBox.confirm(
      `确认将工单「${orderTitle}」派给维修工「${selectedWorker?.name}」吗？`,
      '派单确认',
      { confirmButtonText: '确认派单', cancelButtonText: '取消', type: 'warning' }
    )
  } catch {
    return
  }

  assignLoading.value = true
  try {
    await assignRepair({ repairId: assignRepairId.value, workerId: assignWorkerId.value })
    ElMessage.success('派单成功')
    assignVisible.value = false
    fetchData()
  } catch {} finally { assignLoading.value = false }
}

// 表格多选
function handleSelectionChange(selection) {
  selectedRows.value = selection
}

// 只允许选中 pending 状态的工单
function checkSelectable(row) {
  return row.status === 'pending'
}

// 打开批量派单弹窗
async function showBatchAssign() {
  if (selectedRows.value.length === 0) { ElMessage.warning('请先勾选工单'); return }
  batchAssignWorkerId.value = null
  const res = await listWorkers({ status: 'active', pageSize: 200 })
  batchWorkers.value = res.data.rows || []
  batchAssignVisible.value = true
}

// 批量派单
async function handleBatchAssign() {
  if (!batchAssignWorkerId.value) { ElMessage.warning('请选择维修工'); return }

  const selectedWorker = batchWorkers.value.find(w => w.id === batchAssignWorkerId.value)
  const count = selectedRows.value.length
  const titles = selectedRows.value.map(r => r.title).join('、')

  try {
    await ElMessageBox.confirm(
      `确认将 ${count} 个工单「${titles}」批量派给维修工「${selectedWorker?.name}」吗？`,
      '批量派单确认',
      { confirmButtonText: '确认派单', cancelButtonText: '取消', type: 'warning' }
    )
  } catch {
    return
  }

  batchAssignLoading.value = true
  let successCount = 0
  let failCount = 0
  try {
    for (const row of selectedRows.value) {
      try {
        await assignRepair({ repairId: row.id, workerId: batchAssignWorkerId.value })
        successCount++
      } catch {
        failCount++
      }
    }
    ElMessage.success(`批量派单完成：成功 ${successCount} 单${failCount > 0 ? `，失败 ${failCount} 单` : ''}`)
    batchAssignVisible.value = false
    selectedRows.value = []
    fetchData()
  } catch {} finally { batchAssignLoading.value = false }
}

async function showDetail(repairId) {
  detailLoading.value = true
  detailVisible.value = true
  try {
    const res = await getRepairDetail(repairId)
    detailData.value = res.data
  } catch {
    detailVisible.value = false
  } finally {
    detailLoading.value = false
  }
}

onMounted(fetchData)
</script>

<template>
  <div>
    <el-card>
      <template #header>
        <div class="list-header">
          <h2>工单管理</h2>
          <el-button
            type="warning"
            :disabled="selectedRows.length === 0"
            @click="showBatchAssign"
          >
            批量派单 {{ selectedRows.length > 0 ? `(${selectedRows.length})` : '' }}
          </el-button>
        </div>
      </template>
      <div class="filter-bar">
        <el-select v-model="query.status" placeholder="状态筛选" clearable style="width:120px" @change="() => { query.page = 1; fetchData() }">
          <el-option v-for="o in statusOptions" :key="o.value" :label="o.label" :value="o.value" />
        </el-select>
        <el-input v-model="query.residentName" placeholder="居民姓名" clearable style="width:130px" @clear="() => { query.page = 1; fetchData() }" />
        <el-input v-model="query.workerName" placeholder="维修工姓名" clearable style="width:140px" @clear="() => { query.page = 1; fetchData() }" />
        <el-date-picker
          v-model="query.beginDate"
          type="date"
          placeholder="开始日期"
          value-format="YYYY-MM-DD"
          style="width:140px"
          @clear="() => { query.page = 1; fetchData() }"
        />
        <el-date-picker
          v-model="query.endDate"
          type="date"
          placeholder="结束日期"
          value-format="YYYY-MM-DD"
          style="width:140px"
          @clear="() => { query.page = 1; fetchData() }"
        />
        <el-button type="primary" @click="() => { query.page = 1; fetchData() }">搜索</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>
      <el-table :data="sortedRows" v-loading="loading" border stripe :row-class-name="getRowClass" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="45" :selectable="checkSelectable" />
        <el-table-column type="index" :index="(i) => (query.page - 1) * query.pageSize + i + 1" label="ID" width="60" />
        <el-table-column prop="userName" label="居民" width="100" />
        <el-table-column prop="title" label="标题" min-width="160">
          <template #default="{ row }">
            <span>{{ row.title }}</span>
            <el-tag v-if="row.priority === 'urgent'" type="danger" size="small" style="margin-left:4px">紧急</el-tag>
            <el-tag v-if="isOverdue(row)" type="danger" size="small" effect="dark" style="margin-left:4px">超时</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="维修工" width="150">
          <template #default="{ row }">
            <span v-if="row.workerName" class="worker-cell">
              <el-avatar :size="24" :src="row.workerAvatar" /> {{ row.workerName }}
            </span>
            <span v-else style="color:#94A3B8">-</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }"><StatusTag :status="row.status" /></template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="170" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 'pending'" size="small" type="warning" @click="showAssignDialog(row.id)">派单</el-button>
            <el-button size="small" @click="showDetail(row.id)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="query.page"
          :page-size="query.pageSize"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          :page-sizes="[5, 10, 20, 50]"
          @size-change="(s) => { query.pageSize = s; query.page = 1; fetchData() }"
          @current-change="(p) => { query.page = p; fetchData() }"
        />
      </div>
    </el-card>

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailVisible" title="工单详情" width="560px">
      <el-descriptions v-loading="detailLoading" :column="1" border v-if="detailData">
        <el-descriptions-item label="工单编号">#{{ detailData.id }}</el-descriptions-item>
        <el-descriptions-item label="居民">{{ detailData.userName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="标题">{{ detailData.title }}</el-descriptions-item>
        <el-descriptions-item label="描述">{{ detailData.description || '-' }}</el-descriptions-item>
        <el-descriptions-item label="地址">{{ detailData.address || '-' }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ detailData.contactPhone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <StatusTag :status="detailData.status" />
        </el-descriptions-item>
        <el-descriptions-item label="维修工">
          <span v-if="detailData.workerName" class="worker-cell">
            <el-avatar :size="24" :src="detailData.workerAvatar" /> {{ detailData.workerName }}
          </span>
          <span v-else style="color:#94A3B8">-</span>
        </el-descriptions-item>
        <el-descriptions-item label="维修结果">{{ detailData.result || '-' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ detailData.createTime }}</el-descriptions-item>
        <el-descriptions-item label="派单时间">{{ detailData.assignTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="完成时间">{{ detailData.finishTime || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="assignVisible" title="派单" width="480px">
      <div v-if="currentAssignOrder" class="assign-order-info">
        <el-descriptions :column="1" size="small" border>
          <el-descriptions-item label="工单标题">{{ currentAssignOrder.title }}</el-descriptions-item>
          <el-descriptions-item label="报修居民">{{ currentAssignOrder.userName }}</el-descriptions-item>
          <el-descriptions-item label="当前状态">
            <StatusTag :status="currentAssignOrder.status" />
            <el-tag v-if="isOverdue(currentAssignOrder)" type="danger" size="small" effect="dark" style="margin-left:6px">
              已超时{{ currentAssignOrder.pendingDays }}天
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>
      </div>
      <el-form label-width="80px" style="margin-top:16px">
        <el-form-item label="选择维修工">
          <el-select v-model="assignWorkerId" placeholder="请选择空闲维修工" style="width:100%">
            <el-option
              v-for="w in workers"
              :key="w.id"
              :label="`${w.name} - ${w.skill}`"
              :value="w.id"
            >
              <div class="worker-option">
                <span>{{ w.name }} - {{ w.skill }}</span>
                <el-tag type="success" size="small" effect="plain">空闲</el-tag>
                <span v-if="w.workCount != null" class="worker-count">已处理{{ w.workCount }}单</span>
                <span v-if="w.avgScore != null && w.avgScore > 0" class="worker-score">评分{{ w.avgScore.toFixed(1) }}</span>
              </div>
            </el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="assignVisible = false">取消</el-button>
        <el-button type="primary" :loading="assignLoading" @click="handleAssign">确认派单</el-button>
      </template>
    </el-dialog>

    <!-- 批量派单弹窗 -->
    <el-dialog v-model="batchAssignVisible" title="批量派单" width="520px">
      <div class="batch-info">
        <p>已选择 <strong>{{ selectedRows.length }}</strong> 个待派单工单：</p>
        <el-table :data="selectedRows" border size="small" max-height="200">
          <el-table-column prop="id" label="编号" width="70" />
          <el-table-column prop="title" label="标题" min-width="180" />
          <el-table-column prop="userName" label="居民" width="100" />
          <el-table-column label="状态" width="90">
            <template #default="{ row }"><StatusTag :status="row.status" /></template>
          </el-table-column>
        </el-table>
      </div>
      <el-form label-width="80px" style="margin-top:16px">
        <el-form-item label="选择维修工">
          <el-select v-model="batchAssignWorkerId" placeholder="请选择空闲维修工" style="width:100%">
            <el-option
              v-for="w in batchWorkers"
              :key="w.id"
              :label="`${w.name} - ${w.skill}`"
              :value="w.id"
            >
              <div class="worker-option">
                <span>{{ w.name }} - {{ w.skill }}</span>
                <el-tag type="success" size="small" effect="plain">空闲</el-tag>
                <span v-if="w.workCount != null" class="worker-count">已处理{{ w.workCount }}单</span>
                <span v-if="w.avgScore != null && w.avgScore > 0" class="worker-score">评分{{ w.avgScore.toFixed(1) }}</span>
              </div>
            </el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="batchAssignVisible = false">取消</el-button>
        <el-button type="primary" :loading="batchAssignLoading" @click="handleBatchAssign">确认批量派单</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.list-header { display: flex; justify-content: space-between; align-items: center; }
h2 { margin: 0; font-size: 20px; color: #1E293B; }
.filter-bar { display: flex; gap: 10px; margin-bottom: 16px; flex-wrap: wrap; }
.worker-cell { display: flex; align-items: center; gap: 6px; }
.pagination-wrap { margin-top: 16px; display: flex; justify-content: flex-start; }

/* 超时工单行高亮 */
:deep(.overdue-row > td) {
  background-color: #fff7ed !important;
}
:deep(.overdue-row:hover > td) {
  background-color: #ffedd5 !important;
}

/* 派单弹窗-维修工选项 */
.worker-option {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
}
.worker-count {
  color: #94A3B8;
  font-size: 12px;
  margin-left: auto;
}
.worker-score {
  color: #F59E0B;
  font-size: 12px;
}
.assign-order-info {
  margin-bottom: 4px;
}
.batch-info p {
  margin: 0 0 8px 0;
  color: #475569;
  font-size: 14px;
}
.batch-info strong {
  color: #E65100;
  font-size: 16px;
}
</style>
