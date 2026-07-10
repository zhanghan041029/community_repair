<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { getAdminDashboardStats } from '@/api/repair'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import {
  DocumentAdd, Timer, Checked, User,
  TrendCharts, Warning, Tools, List
} from '@element-plus/icons-vue'

const router = useRouter()
const loading = ref(false)
const stats = ref({
  todayNew: 0,
  pendingTotal: 0,
  monthCompleted: 0,
  totalWorkers: 0
})
const dailyTrend = ref([])
const statusDist = ref({})
const recentList = ref([])

let lineChart = null
let barChart = null

function getWeekDay(dateStr) {
  const days = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
  const d = new Date(dateStr)
  return days[d.getDay()]
}

function initLineChart() {
  const el = document.getElementById('lineChart')
  if (!el) return
  lineChart = echarts.init(el)
  const xData = dailyTrend.value.map(item => getWeekDay(item.date))
  const yData = dailyTrend.value.map(item => item.count)

  lineChart.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: 50, right: 30, top: 30, bottom: 30 },
    xAxis: {
      type: 'category',
      data: xData,
      axisLine: { lineStyle: { color: '#E2E8F0' } },
      axisLabel: { color: '#94A3B8' }
    },
    yAxis: {
      type: 'value',
      splitLine: { lineStyle: { color: '#F1F5F9' } },
      axisLabel: { color: '#94A3B8' }
    },
    series: [{
      data: yData,
      type: 'line',
      smooth: true,
      symbol: 'circle',
      symbolSize: 6,
      lineStyle: { color: '#3B82F6', width: 2 },
      itemStyle: { color: '#3B82F6', borderWidth: 2, borderColor: '#fff' },
      areaStyle: {
        color: {
          type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: 'rgba(59,130,246,0.2)' },
            { offset: 1, color: 'rgba(59,130,246,0)' }
          ]
        }
      }
    }]
  })
}

function initBarChart() {
  const el = document.getElementById('barChart')
  if (!el) return
  barChart = echarts.init(el)
  const entries = Object.entries(statusDist.value)
  const colors = ['#3B82F6', '#10B981', '#F59E0B', '#8B5CF6', '#EF4444']

  barChart.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: 50, right: 20, top: 20, bottom: 30 },
    xAxis: {
      type: 'category',
      data: entries.map(([k]) => k),
      axisLine: { lineStyle: { color: '#E2E8F0' } },
      axisLabel: { color: '#64748B', fontSize: 12 }
    },
    yAxis: {
      type: 'value',
      splitLine: { lineStyle: { color: '#F1F5F9' } },
      axisLabel: { color: '#94A3B8' }
    },
    series: [{
      data: entries.map(([_, v], i) => ({
        value: v,
        itemStyle: { color: colors[i % colors.length], borderRadius: [4, 4, 0, 0] }
      })),
      type: 'bar',
      barWidth: 32
    }]
  })
}

function handleResize() {
  lineChart?.resize()
  barChart?.resize()
}

async function fetchData() {
  loading.value = true
  try {
    const res = await getAdminDashboardStats()
    const data = res.data
    stats.value = {
      todayNew: data.todayNew || 0,
      pendingTotal: data.pendingTotal || 0,
      monthCompleted: data.monthCompleted || 0,
      totalWorkers: data.totalWorkers || 0
    }
    dailyTrend.value = data.dailyTrend || []
    statusDist.value = data.statusDist || {}
    recentList.value = data.recentList || []
    await nextTick()
    initLineChart()
    initBarChart()
  } catch (err) {
    ElMessage.error(err.msg || '获取数据失败')
  } finally {
    loading.value = false
  }
}

function getStatusText(status) {
  const map = {
    pending: '待派单',
    assigned: '已派单',
    processing: '处理中',
    completed: '已完成',
    cancelled: '已取消'
  }
  return map[status] || status
}

function getStatusTagType(status) {
  const map = {
    pending: 'warning',
    assigned: 'primary',
    processing: 'info',
    completed: 'success',
    cancelled: 'danger'
  }
  return map[status] || 'info'
}

onMounted(() => {
  fetchData()
  window.addEventListener('resize', handleResize)
})
</script>

<template>
  <div v-loading="loading">
    <!-- 顶部统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div>
              <div class="stat-label">今日新增工单</div>
              <div class="stat-value">{{ stats.todayNew }}</div>
              <div class="stat-trend up">
                <el-icon><TrendCharts /></el-icon>
                <span>较昨日</span>
              </div>
            </div>
            <div class="stat-icon blue">
              <el-icon :size="24"><DocumentAdd /></el-icon>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div>
              <div class="stat-label">待处理工单</div>
              <div class="stat-value">{{ stats.pendingTotal }}</div>
              <div class="stat-trend down">
                <el-icon><Timer /></el-icon>
                <span>实时待办</span>
              </div>
            </div>
            <div class="stat-icon orange">
              <el-icon :size="24"><Warning /></el-icon>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div>
              <div class="stat-label">本月完工数</div>
              <div class="stat-value">{{ stats.monthCompleted }}</div>
              <div class="stat-trend up">
                <el-icon><Checked /></el-icon>
                <span>较上月</span>
              </div>
            </div>
            <div class="stat-icon green">
              <el-icon :size="24"><Tools /></el-icon>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div>
              <div class="stat-label">在线维修工</div>
              <div class="stat-value">{{ stats.totalWorkers }}<span class="unit">人</span></div>
              <div class="stat-trend up">
                <el-icon><User /></el-icon>
                <span>实时在线</span>
              </div>
            </div>
            <div class="stat-icon purple">
              <el-icon :size="24"><User /></el-icon>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 中间图表区域 -->
    <el-row :gutter="16" class="chart-row">
      <el-col :xs="24" :lg="16">
        <el-card class="chart-card">
          <div class="chart-header">
            <div>
              <div class="chart-title">近7天工单趋势</div>
              <div class="chart-subtitle">每日工单数量变化统计</div>
            </div>
          </div>
          <div id="lineChart" class="chart-body"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="8">
        <el-card class="chart-card">
          <div class="chart-header">
            <div>
              <div class="chart-title">工单状态分布</div>
              <div class="chart-subtitle">各类工单占比统计</div>
            </div>
          </div>
          <div id="barChart" class="chart-body"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 底部操作与动态 -->
    <el-row :gutter="16" class="bottom-row">
      <el-col :xs="24" :lg="8">
        <el-card class="action-card">
          <template #header>
            <span class="card-header-title">快捷操作</span>
          </template>
          <div class="action-grid">
            <div class="action-item" @click="router.push('/repair/manage')">
              <div class="action-icon blue">
                <el-icon :size="22"><DocumentAdd /></el-icon>
              </div>
              <div class="action-name">工单管理</div>
            </div>
            <div class="action-item" @click="router.push('/workers')">
              <div class="action-icon green">
                <el-icon :size="22"><User /></el-icon>
              </div>
              <div class="action-name">维修工管理</div>
            </div>
            <div class="action-item" @click="router.push('/residents')">
              <div class="action-icon orange">
                <el-icon :size="22"><List /></el-icon>
              </div>
              <div class="action-name">居民管理</div>
            </div>
            <div class="action-item" @click="router.push('/repair/manage')">
              <div class="action-icon purple">
                <el-icon :size="22"><Tools /></el-icon>
              </div>
              <div class="action-name">派单处理</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="16">
        <el-card class="activity-card">
          <template #header>
            <div class="activity-header">
              <span class="card-header-title">最近动态</span>
              <el-button link type="primary" size="small" @click="router.push('/repair/manage')">查看全部</el-button>
            </div>
          </template>
          <div class="activity-list">
            <div v-for="item in recentList.slice(0, 6)" :key="item.id" class="activity-item">
              <div class="activity-dot" :class="item.status"></div>
              <div class="activity-content">
                <div class="activity-title">
                  工单 #{{ item.id }} {{ getStatusText(item.status) }}
                  <el-tag :type="getStatusTagType(item.status)" size="small" class="status-tag">{{ getStatusText(item.status) }}</el-tag>
                </div>
                <div class="activity-desc">{{ item.title }}</div>
              </div>
              <div class="activity-time">{{ item.createTime }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped lang="scss">
.stats-row { margin-bottom: 16px; }
.stat-card {
  margin-bottom: 16px;
  .stat-content {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
  }
  .stat-label {
    font-size: 13px;
    color: #64748B;
    margin-bottom: 8px;
  }
  .stat-value {
    font-size: 28px;
    font-weight: 700;
    color: #1E293B;
    line-height: 1;
    .unit {
      font-size: 14px;
      font-weight: 400;
      color: #64748B;
      margin-left: 4px;
    }
  }
  .stat-trend {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 12px;
    margin-top: 8px;
    &.up { color: #10B981; }
    &.down { color: #EF4444; }
  }
  .stat-icon {
    width: 44px;
    height: 44px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    &.blue { background: #3B82F6; }
    &.orange { background: #F59E0B; }
    &.green { background: #10B981; }
    &.purple { background: #8B5CF6; }
  }
}

.chart-row { margin-bottom: 16px; }
.chart-card {
  margin-bottom: 16px;
  .chart-header {
    margin-bottom: 12px;
    .chart-title {
      font-size: 15px;
      font-weight: 600;
      color: #1E293B;
    }
    .chart-subtitle {
      font-size: 12px;
      color: #94A3B8;
      margin-top: 4px;
    }
  }
  .chart-body {
    width: 100%;
    height: 280px;
  }
}

.bottom-row {
  .action-card,
  .activity-card {
    margin-bottom: 16px;
  }
}

.card-header-title {
  font-weight: 600;
  color: #1E293B;
  font-size: 15px;
}

.action-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  .action-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 20px 12px;
    border-radius: 8px;
    background: #F8FAFC;
    cursor: pointer;
    transition: all 0.2s;
    &:hover {
      background: #F1F5F9;
      transform: translateY(-2px);
    }
    .action-icon {
      width: 40px;
      height: 40px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      margin-bottom: 8px;
      &.blue { background: #3B82F6; }
      &.green { background: #10B981; }
      &.orange { background: #F59E0B; }
      &.purple { background: #8B5CF6; }
    }
    .action-name {
      font-size: 13px;
      color: #475569;
    }
  }
}

.activity-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.activity-list {
  .activity-item {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid #F1F5F9;
    &:last-child { border-bottom: none; }
    .activity-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      margin-top: 6px;
      flex-shrink: 0;
      &.pending { background: #F59E0B; }
      &.assigned { background: #3B82F6; }
      &.processing { background: #8B5CF6; }
      &.completed { background: #10B981; }
      &.cancelled { background: #EF4444; }
    }
    .activity-content {
      flex: 1;
      min-width: 0;
      .activity-title {
        font-size: 14px;
        font-weight: 500;
        color: #1E293B;
        display: flex;
        align-items: center;
        gap: 8px;
        .status-tag { font-size: 11px; }
      }
      .activity-desc {
        font-size: 13px;
        color: #64748B;
        margin-top: 4px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
    }
    .activity-time {
      font-size: 12px;
      color: #94A3B8;
      white-space: nowrap;
    }
  }
}
</style>
