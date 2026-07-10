<script setup>
import { ref, onMounted, reactive } from 'vue'
import { listRepairs, cancelRepair } from '@/api/repair'
import { createEvaluation } from '@/api/evaluation'
import { ElMessageBox, ElMessage } from 'element-plus'
import StatusTag from '@/components/StatusTag.vue'
import StarRating from '@/components/StarRating.vue'
import RepairDetailDialog from '@/views/resident/RepairDetailDialog.vue'

const loading = ref(false)
const rows = ref([])
const total = ref(0)
const detailVisible = ref(false)
const detailId = ref(null)
const evalVisible = ref(false)
const evalRepairId = ref(null)
const evalScore = ref(5)
const evalComment = ref('')
const evalLoading = ref(false)

const query = reactive({ page: 1, pageSize: 10, status: '' })

const statusOptions = [
  { label: '全部', value: '' }, { label: '待派单', value: 'pending' },
  { label: '已派单', value: 'assigned' }, { label: '处理中', value: 'processing' },
  { label: '已完成', value: 'completed' }, { label: '已取消', value: 'cancelled' }
]

async function fetchData() {
  loading.value = true
  try {
    const res = await listRepairs({ page: query.page, pageSize: query.pageSize, status: query.status || undefined })
    rows.value = res.data.rows || []
    total.value = res.data.total || 0
  } finally { loading.value = false }
}

function handlePageChange(p) { query.page = p; fetchData() }
function handleSizeChange(s) { query.pageSize = s; query.page = 1; fetchData() }

async function handleCancel(id) {
  try {
    await ElMessageBox.confirm('确定取消该工单?', '提示', { type: 'warning' })
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

onMounted(fetchData)
</script>

<template>
  <div>
    <el-card>
      <template #header>
        <div class="list-header">
          <h2>我的工单</h2>
          <el-select v-model="query.status" placeholder="筛选" clearable style="width:120px" @change="fetchData">
            <el-option v-for="o in statusOptions" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </div>
      </template>
      <el-table :data="rows" v-loading="loading" border stripe>
        <el-table-column prop="id" label="编号" width="80" />
        <el-table-column prop="title" label="标题" min-width="150">
          <template #default="{ row }">
            <span>{{ row.title }}</span>
            <el-tag v-if="row.priority === 'urgent'" type="danger" size="small" style="margin-left:6px">紧急</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="现场照片" width="100" align="center">
          <template #default="{ row }">
            <el-image
              v-if="row.image"
              :src="'http://localhost:8080/api' + row.image"
              fit="cover"
              style="width:60px;height:45px;border-radius:4px;cursor:pointer;"
              :preview-src-list="['http://localhost:8080/api' + row.image]"
              preview-teleported
            />
            <span v-else style="color:#CBD5E1">-</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }"><StatusTag :status="row.status" /></template>
        </el-table-column>
        <el-table-column label="维修工" width="150">
          <template #default="{ row }">
            <span v-if="row.workerName" class="worker-cell">
              <el-avatar :size="24" :src="row.workerAvatar" /> {{ row.workerName }}
            </span>
            <span v-else style="color:#94A3B8">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="170" />
        <el-table-column label="操作" width="180" fixed="right" align="center">
          <template #default="{ row }">
            <el-button size="small" @click="showDetail(row.id)">详情</el-button>
            <el-button v-if="row.status === 'pending'" size="small" type="danger" @click="handleCancel(row.id)">取消</el-button>
            <el-button v-if="row.status === 'completed'" size="small" type="success" @click="showEval(row.id)">评价</el-button>
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
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>
    <RepairDetailDialog v-model:visible="detailVisible" :repair-id="detailId" @refresh="fetchData" />

    <el-dialog v-model="evalVisible" title="评价工单" width="400px">
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

<style scoped>
.list-header { display: flex; justify-content: space-between; align-items: center; }
h2 { margin: 0; font-size: 20px; color: #1E293B; }
.worker-cell { display: flex; align-items: center; gap: 6px; }
.pagination-wrap { margin-top: 16px; display: flex; justify-content: flex-start; }
.eval-form { display: flex; flex-direction: column; gap: 16px; }
.eval-stars { display: flex; align-items: center; gap: 12px; }
.eval-score-text { font-size: 18px; font-weight: 600; color: #F59E0B; }
</style>