<script setup>
import { ref, onMounted, reactive } from 'vue'
import { getMyEvaluations } from '@/api/evaluation'
import StarRating from '@/components/StarRating.vue'

const loading = ref(false)
const rows = ref([])
const total = ref(0)

const query = reactive({ page: 1, pageSize: 10 })

async function fetchData() {
  loading.value = true
  try {
    const res = await getMyEvaluations({ page: query.page, pageSize: query.pageSize })
    rows.value = res.data.rows || []
    total.value = res.data.total || 0
  } finally { loading.value = false }
}

function handlePageChange(p) { query.page = p; fetchData() }
function handleSizeChange(s) { query.pageSize = s; query.page = 1; fetchData() }

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return dateStr.slice(0, 16).replace('T', ' ')
}

onMounted(fetchData)
</script>

<template>
  <div>
    <el-card>
      <template #header>
        <div class="list-header">
          <h2>我的评价</h2>
        </div>
      </template>
      <el-table :data="rows" v-loading="loading" border stripe>
        <el-table-column prop="repairTitle" label="工单标题" min-width="200" />
        <el-table-column label="评分" width="180">
          <template #default="{ row }">
            <div class="score-cell">
              <StarRating :model-value="row.score" />
              <span class="score-text">{{ row.score }}分</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="comment" label="评价内容" min-width="250" show-overflow-tooltip />
        <el-table-column label="维修工回复" min-width="200">
          <template #default="{ row }">
            <div v-if="row.reply" class="reply-cell">
              <span>{{ row.reply }}</span>
              <span class="reply-time">{{ formatDate(row.replyTime) }}</span>
            </div>
            <span v-else style="color:#CBD5E1">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="评价时间" width="170">
          <template #default="{ row }">{{ formatDate(row.createTime) }}</template>
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
.score-cell { display: flex; align-items: center; gap: 8px; }
.score-text { font-size: 13px; color: #F59E0B; font-weight: 600; }
.pagination-wrap { margin-top: 16px; display: flex; justify-content: flex-start; }
.reply-cell { display: flex; flex-direction: column; gap: 2px; font-size: 13px; color: #16A34A; }
.reply-time { font-size: 11px; color: #94A3B8; }
</style>
