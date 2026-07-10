<script setup>
import { ref, reactive, onMounted } from 'vue'
import request from '@/utils/request'
import { ElMessageBox, ElMessage } from 'element-plus'

const loading = ref(false)
const rows = ref([])
const total = ref(0)
const query = reactive({ page: 1, pageSize: 10, name: '', phone: '' })

const detailVisible = ref(false)
const detailData = ref(null)

function showDetail(row) {
  detailData.value = { ...row }
  detailVisible.value = true
}

async function fetchData() {
  loading.value = true
  try {
    const res = await request({
      url: '/api/residents',
      method: 'get',
      params: {
        page: query.page,
        pageSize: query.pageSize,
        name: query.name || undefined,
        phone: query.phone || undefined
      }
    })
    rows.value = res.data.rows || []
    total.value = res.data.total || 0
  } finally { loading.value = false }
}

function handleSearch() {
  query.page = 1
  fetchData()
}

function handleReset() {
  query.name = ''
  query.phone = ''
  query.page = 1
  fetchData()
}

onMounted(fetchData)
</script>

<template>
  <div>
    <el-card>
      <template #header>
        <div class="list-header">
          <h2>居民管理</h2>
        </div>
      </template>
      <div class="filter-bar">
        <el-input v-model="query.name" placeholder="搜索姓名" clearable style="width:150px" @clear="handleSearch" />
        <el-input v-model="query.phone" placeholder="搜索手机号" clearable style="width:160px" @clear="handleSearch" />
        <div class="filter-actions">
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </div>
      </div>
      <el-table :data="rows" v-loading="loading" border stripe>
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column label="头像" width="80">
          <template #default="{ row }"><el-avatar :size="36" :src="row.avatar" /></template>
        </el-table-column>
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="address" label="地址" min-width="150" />
        <el-table-column prop="createTime" label="注册时间" width="170" />
        <el-table-column label="操作" width="150" fixed="right" align="center" header-align="center">
          <template #default="{ row }">
            <div class="action-btns">
              <el-button size="small" @click="showDetail(row)">详情</el-button>
              <el-button size="small" type="danger" @click="async () => {
                try {
                  await ElMessageBox.confirm('确定删除该居民?', '提示', { type: 'warning' })
                  await request({ url: `/api/residents/${row.id}`, method: 'delete' })
                  ElMessage.success('删除成功')
                  fetchData()
                } catch {}
              }">删除</el-button>
            </div>
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

    <!-- 居民详情弹窗 -->
    <el-dialog v-model="detailVisible" title="居民详情" width="400px">
      <div v-if="detailData" class="detail-content">
        <div class="detail-avatar">
          <el-avatar :size="64" :src="detailData.avatar" />
        </div>
        <div class="detail-item">
          <span class="detail-label">居民ID：</span>
          <span class="detail-value">{{ detailData.id }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">姓名：</span>
          <span class="detail-value">{{ detailData.name }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">手机号：</span>
          <span class="detail-value">{{ detailData.phone }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">地址：</span>
          <span class="detail-value">{{ detailData.address || '-' }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">注册时间：</span>
          <span class="detail-value">{{ detailData.createTime }}</span>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.list-header { display: flex; justify-content: space-between; align-items: center; }
h2 { margin: 0; font-size: 20px; color: #1E293B; }
.filter-bar { display: flex; gap: 12px; margin-bottom: 16px; align-items: center; }
.filter-actions { margin-left: auto; display: flex; gap: 8px; }
.pagination-wrap { margin-top: 16px; display: flex; justify-content: flex-start; }

/* 操作按钮居中 */
.action-btns {
  display: flex;
  justify-content: center;
  gap: 6px;
  flex-wrap: wrap;
}

/* 详情弹窗 */
.detail-content {
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.detail-avatar {
  display: flex;
  justify-content: center;
  margin-bottom: 8px;
}
.detail-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}
.detail-label {
  color: #94A3B8;
  min-width: 70px;
  text-align: right;
}
.detail-value {
  color: #1E293B;
  font-weight: 500;
  flex: 1;
}
</style>