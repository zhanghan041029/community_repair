<script setup>
import { ref, onMounted, reactive } from 'vue'
import { listActiveWorkers } from '@/api/worker'
import StarRating from '@/components/StarRating.vue'

const loading = ref(false)
const rows = ref([])
const total = ref(0)
const searchName = ref('')

const query = reactive({ page: 1, pageSize: 10 })

async function fetchData() {
  loading.value = true
  try {
    const res = await listActiveWorkers({ page: query.page, pageSize: query.pageSize, name: searchName.value || undefined })
    rows.value = res.data.rows || []
    total.value = res.data.total || 0
  } finally { loading.value = false }
}

function handleSearch() { query.page = 1; fetchData() }
function handlePageChange(p) { query.page = p; fetchData() }
function handleSizeChange(s) { query.pageSize = s; query.page = 1; fetchData() }

function formatScore(score) {
  if (score == null) return '暂无评分'
  return score.toFixed(1) + '分'
}

onMounted(fetchData)
</script>

<template>
  <div>
    <el-card>
      <template #header>
        <div class="list-header">
          <h2>维修工信息</h2>
          <div class="search-wrap">
            <el-input
              v-model="searchName"
              placeholder="搜索维修工姓名"
              clearable
              style="width: 200px"
              @keyup.enter="handleSearch"
              @clear="handleSearch"
            >
              <template #append>
                <el-button @click="handleSearch">搜索</el-button>
              </template>
            </el-input>
          </div>
        </div>
      </template>
      <el-table :data="rows" v-loading="loading" border stripe>
        <el-table-column label="头像" width="80">
          <template #default="{ row }">
            <el-avatar :size="40" :src="row.avatar" />
          </template>
        </el-table-column>
        <el-table-column prop="name" label="姓名" min-width="100" />
        <el-table-column prop="skill" label="技能特长" min-width="150" />
        <el-table-column label="评分" width="160">
          <template #default="{ row }">
            <div class="score-cell">
              <StarRating :model-value="Math.round(row.avgScore || 0)" />
              <span class="score-text">{{ formatScore(row.avgScore) }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="完成工单" width="100" align="center">
          <template #default="{ row }">
            <el-tag type="success" effect="plain">{{ row.workCount || 0 }}</el-tag>
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
  </div>
</template>

<style scoped>
.list-header { display: flex; justify-content: space-between; align-items: center; }
h2 { margin: 0; font-size: 20px; color: #1E293B; }
.search-wrap { display: flex; align-items: center; }
.score-cell { display: flex; align-items: center; gap: 8px; }
.score-text { font-size: 13px; color: #F59E0B; font-weight: 600; min-width: 48px; }
.pagination-wrap { margin-top: 16px; display: flex; justify-content: flex-start; }
</style>
