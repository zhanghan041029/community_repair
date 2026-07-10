<script setup>
import { ref, reactive, onMounted } from 'vue'
import { listWorkers, addWorker, reviewWorker, deleteWorker } from '@/api/worker'
import { ElMessageBox, ElMessage } from 'element-plus'
import StatusTag from '@/components/StatusTag.vue'

const loading = ref(false)
const rows = ref([])
const total = ref(0)
const query = reactive({ page: 1, pageSize: 10, name: '', phone: '', status: '' })
const addVisible = ref(false)
const addForm = reactive({ name: '', phone: '', skill: '', username: '', password: '' })
const addLoading = ref(false)

const detailVisible = ref(false)
const detailData = ref(null)

function handleReset() {
  query.name = ''
  query.phone = ''
  query.status = ''
  query.page = 1
  fetchData()
}

async function fetchData() {
  loading.value = true
  try {
    const res = await listWorkers({
      page: query.page, pageSize: query.pageSize,
      name: query.name || undefined,
      phone: query.phone || undefined,
      status: query.status || undefined
    })
    rows.value = res.data.rows || []
    total.value = res.data.total || 0
  } finally { loading.value = false }
}

async function handleApprove(workerId) {
  try { await reviewWorker({ workerId, approved: true }); ElMessage.success('已通过'); fetchData() } catch {}
}

async function handleReject(workerId) {
  try {
    const { value } = await ElMessageBox.prompt('请输入拒绝原因', '拒绝审核', { type: 'warning' })
    await reviewWorker({ workerId, approved: false, rejectReason: value })
    ElMessage.success('已拒绝')
    fetchData()
  } catch { /* cancelled */ }
}

async function handleDelete(id) {
  try {
    await ElMessageBox.confirm('确定删除?', '提示', { type: 'warning' })
    await deleteWorker(id)
    ElMessage.success('删除成功')
    fetchData()
  } catch {}
}

function showDetail(row) {
  detailData.value = { ...row }
  detailVisible.value = true
}

async function handleAdd() {
  addLoading.value = true
  try {
    await addWorker({ ...addForm })
    ElMessage.success('添加成功')
    addVisible.value = false
    fetchData()
  } catch {} finally { addLoading.value = false }
}

onMounted(fetchData)
</script>

<template>
  <div>
    <el-card>
      <template #header>
        <div class="list-header">
          <h2>维修工管理</h2>
          <el-button type="primary" @click="addVisible = true">添加维修工</el-button>
        </div>
      </template>
      <div class="filter-bar">
        <el-input v-model="query.name" placeholder="搜索姓名" clearable style="width:150px" @clear="() => { query.page = 1; fetchData() }" />
        <el-input v-model="query.phone" placeholder="搜索手机号" clearable style="width:150px" @clear="() => { query.page = 1; fetchData() }" />
        <el-select v-model="query.status" placeholder="状态筛选" clearable style="width:120px" @clear="() => { query.page = 1; fetchData() }">
          <el-option label="正常" value="active" /><el-option label="待审核" value="pending" /><el-option label="已拒绝" value="rejected" />
        </el-select>
        <el-button type="primary" @click="() => { query.page = 1; fetchData() }">搜索</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>
      <el-table :data="rows" v-loading="loading" border stripe height="calc(100vh - 280px)">
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column label="头像" width="80">
          <template #default="{ row }"><el-avatar :size="36" :src="row.avatar" /></template>
        </el-table-column>
        <el-table-column prop="skill" label="技能" min-width="150" />
        <el-table-column label="审核状态" width="100">
          <template #default="{ row }"><StatusTag :status="row.status" type="worker" /></template>
        </el-table-column>
        <el-table-column prop="registerType" label="来源" width="100">
          <template #default="{ row }">{{ row.registerType === 'register' ? '自主注册' : '管理员添加' }}</template>
        </el-table-column>
        <el-table-column prop="workCount" label="工单数" width="80" />
        <el-table-column label="操作" width="200" fixed="right" align="center">
          <template #default="{ row }">
            <div style="display:flex;justify-content:center;gap:4px;flex-wrap:wrap">
              <el-button size="small" @click="showDetail(row)">详情</el-button>
              <template v-if="row.status === 'pending'">
                <el-button size="small" type="success" @click="handleApprove(row.id)">通过</el-button>
                <el-button size="small" type="danger" @click="handleReject(row.id)">拒绝</el-button>
              </template>
              <el-button v-else size="small" type="danger" @click="handleDelete(row.id)">删除</el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-wrap">
        <el-pagination v-model:current-page="query.page" :page-size="query.pageSize" :total="total" layout="total,sizes,prev,pager,next,jumper" :page-sizes="[5,10,20,50]" @size-change="(s)=>{query.pageSize=s;query.page=1;fetchData()}" @current-change="(p)=>{query.page=p;fetchData()}" />
      </div>
    </el-card>

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailVisible" title="维修工详情" width="420px">
      <el-descriptions :column="1" border v-if="detailData">
        <el-descriptions-item label="ID">{{ detailData.id }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{ detailData.name }}</el-descriptions-item>
        <el-descriptions-item label="头像">
          <el-avatar :size="48" :src="detailData.avatar" />
        </el-descriptions-item>
        <el-descriptions-item label="手机号">{{ detailData.phone }}</el-descriptions-item>
        <el-descriptions-item label="技能">{{ detailData.skill || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审核状态">
          <StatusTag :status="detailData.status" type="worker" />
        </el-descriptions-item>
        <el-descriptions-item label="来源">
          {{ detailData.registerType === 'register' ? '自主注册' : '管理员添加' }}
        </el-descriptions-item>
        <el-descriptions-item label="工单数">{{ detailData.workCount || 0 }}</el-descriptions-item>
        <el-descriptions-item label="平均评分">
          <el-rate :model-value="detailData.avgScore || 0" disabled show-score />
        </el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="addVisible" title="添加维修工" width="450px">
      <el-form :model="addForm" label-width="80px">
        <el-form-item label="姓名"><el-input v-model="addForm.name" /></el-form-item>
        <el-form-item label="手机号"><el-input v-model="addForm.phone" /></el-form-item>
        <el-form-item label="技能"><el-input v-model="addForm.skill" /></el-form-item>
        <el-form-item label="用户名"><el-input v-model="addForm.username" /></el-form-item>
        <el-form-item label="密码"><el-input v-model="addForm.password" type="password" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addVisible = false">取消</el-button>
        <el-button type="primary" :loading="addLoading" @click="handleAdd">确认添加</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.list-header { display:flex; justify-content:space-between; align-items:center; }
h2 { margin:0; font-size:20px; color:#1E293B; }
.filter-bar { display:flex; gap:12px; margin-bottom:16px; }
.pagination-wrap { margin-top:16px; display:flex; justify-content:flex-start; }
</style>