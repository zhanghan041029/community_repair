<script setup>
import { ref, onMounted, computed } from 'vue'
import { getRepairStats } from '@/api/repair'
import { Tickets, Clock, Check, Loading, Close, Sort } from '@element-plus/icons-vue'
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart, BarChart } from 'echarts/charts'
import { TitleComponent, TooltipComponent, LegendComponent, GridComponent } from 'echarts/components'

use([CanvasRenderer, PieChart, BarChart, TitleComponent, TooltipComponent, LegendComponent, GridComponent])

const loading = ref(false)
const stats = ref({ total: 0, pending: 0, assigned: 0, processing: 0, completed: 0, cancelled: 0 })

const cards = [
  { label: '工单总数', key: 'total', icon: Tickets, color: '#3B82F6', bg: '#EFF6FF' },
  { label: '待派单', key: 'pending', icon: Clock, color: '#F59E0B', bg: '#FFFBEB' },
  { label: '已派单', key: 'assigned', icon: Sort, color: '#8B5CF6', bg: '#F5F3FF' },
  { label: '处理中', key: 'processing', icon: Loading, color: '#3B82F6', bg: '#EFF6FF' },
  { label: '已完成', key: 'completed', icon: Check, color: '#10B981', bg: '#ECFDF5' },
  { label: '已取消', key: 'cancelled', icon: Close, color: '#94A3B8', bg: '#F8FAFC' }
]

const pieOption = computed(() => ({
  title: { text: '工单状态分布', left: 'center', textStyle: { fontSize: 16, color: '#1E293B', fontWeight: 600 } },
  tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
  legend: { bottom: 10, textStyle: { fontSize: 12 } },
  color: ['#F59E0B', '#8B5CF6', '#3B82F6', '#10B981', '#94A3B8'],
  series: [{
    type: 'pie',
    radius: ['40%', '70%'],
    avoidLabelOverlap: true,
    itemStyle: { borderRadius: 8, borderColor: '#fff', borderWidth: 2 },
    label: { show: true, formatter: '{b}\n{d}%' },
    data: [
      { name: '待派单', value: stats.value.pending },
      { name: '已派单', value: stats.value.assigned },
      { name: '处理中', value: stats.value.processing },
      { name: '已完成', value: stats.value.completed },
      { name: '已取消', value: stats.value.cancelled }
    ]
  }]
}))

const barOption = computed(() => ({
  title: { text: '各状态工单数量', left: 'center', textStyle: { fontSize: 16, color: '#1E293B', fontWeight: 600 } },
  tooltip: { trigger: 'axis' },
  grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
  xAxis: {
    type: 'category',
    data: ['待派单', '已派单', '处理中', '已完成', '已取消'],
    axisLabel: { color: '#64748B' }
  },
  yAxis: {
    type: 'value',
    minInterval: 1,
    axisLabel: { color: '#64748B' }
  },
  series: [{
    type: 'bar',
    barWidth: '50%',
    itemStyle: { borderRadius: [6, 6, 0, 0] },
    data: [
      { value: stats.value.pending, itemStyle: { color: '#F59E0B' } },
      { value: stats.value.assigned, itemStyle: { color: '#8B5CF6' } },
      { value: stats.value.processing, itemStyle: { color: '#3B82F6' } },
      { value: stats.value.completed, itemStyle: { color: '#10B981' } },
      { value: stats.value.cancelled, itemStyle: { color: '#94A3B8' } }
    ]
  }]
}))

async function fetchData() {
  loading.value = true
  try {
    const res = await getRepairStats()
    stats.value = res.data
  } finally { loading.value = false }
}

onMounted(fetchData)
</script>

<template>
  <div class="stats-page">
    <div class="page-header">
      <h2>工单统计</h2>
    </div>
    <div v-loading="loading">
      <div class="stats-grid">
        <el-card v-for="card in cards" :key="card.key" shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" :style="{ background: card.bg, color: card.color }">
              <el-icon :size="28"><component :is="card.icon" /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-label">{{ card.label }}</div>
              <div class="stat-value" :style="{ color: card.color }">{{ stats[card.key] }}</div>
            </div>
          </div>
        </el-card>
      </div>

      <div class="charts-row">
        <el-card shadow="hover" class="chart-card">
          <v-chart :option="pieOption" style="height: 350px" autoresize />
        </el-card>
        <el-card shadow="hover" class="chart-card">
          <v-chart :option="barOption" style="height: 350px" autoresize />
        </el-card>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.stats-page { padding: 4px; }
.page-header { margin-bottom: 20px; h2 { margin: 0; font-size: 20px; color: #1E293B; } }
.stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 20px; }
.stat-card { border-radius: 12px; :deep(.el-card__body) { padding: 20px; } }
.stat-content { display: flex; align-items: center; gap: 16px; }
.stat-icon {
  width: 56px; height: 56px; border-radius: 12px;
  display: flex; align-items: center; justify-content: center;
}
.stat-info { flex: 1; }
.stat-label { font-size: 14px; color: #64748B; margin-bottom: 4px; }
.stat-value { font-size: 28px; font-weight: 700; }
.charts-row { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }
.chart-card { border-radius: 12px; }
</style>
