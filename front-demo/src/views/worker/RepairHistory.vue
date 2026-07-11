<script setup>
import { ref, reactive, onMounted, onUnmounted, nextTick } from 'vue'

// ── 画布 ──
const canvas = ref(null)
const W = 600
const H = 450

// ── 游戏状态 ──
const state = reactive({
  score: 0,
  best: parseInt(localStorage.getItem('bridgeBest') || '0'),
  phase: 'stretching', // stretching | walking | falling | success | gameover
  platform1: 120,
  gapStart: 220,
  gapWidth: 160,
  platform2Right: 580,
  bridgeLen: 0,
  maxBridgeLen: 350,
  manX: 120,
  manY: 340,
  falling: 0,
  walkProgress: 0,
})

// 响应式变量（模板显示用）
const score = ref(0)
const bestScore = ref(state.best)
const gameOver = ref(false)
const gameStarted = ref(false)

let animId = null
let stretchInterval = null

// ── 绘制函数 ──
function drawScene(ctx) {
  ctx.clearRect(0, 0, W, H)

  // 天空渐变
  const grad = ctx.createLinearGradient(0, 0, 0, H)
  grad.addColorStop(0, '#87CEEB')
  grad.addColorStop(0.8, '#E0F7FA')
  ctx.fillStyle = grad
  ctx.fillRect(0, 0, W, H)

  // 地面
  const groundY = 370
  ctx.fillStyle = '#5D4037'
  ctx.fillRect(0, groundY, W, H - groundY)
  // 草地
  ctx.fillStyle = '#4CAF50'
  ctx.fillRect(0, groundY - 6, W, 8)

  // 平台1（左边）
  drawPlatform(ctx, 0, state.platform1, groundY)
  // 平台2（右边）
  drawPlatform(ctx, state.platform1 + state.gapWidth, state.platform2Right, groundY)

  // 桥（杆子）
  if (state.bridgeLen > 0) {
    ctx.save()
    ctx.translate(state.platform1, groundY)
    // 杆子从平台上方向右旋转倒下
    const angle = Math.min(state.bridgeLen / 200, Math.PI / 2.2)
    ctx.rotate(-angle + Math.PI / 2)
    ctx.fillStyle = '#795548'
    ctx.fillRect(-5, 0, 10, state.bridgeLen)
    ctx.restore()
  }

  // 小人
  drawMan(ctx, state.manX, state.manY, state.phase)
}

function drawPlatform(ctx, x1, x2, groundY) {
  ctx.fillStyle = '#8D6E63'
  ctx.fillRect(x1, groundY - 20, x2 - x1, 20)
  ctx.strokeStyle = '#5D4037'
  ctx.lineWidth = 2
  ctx.strokeRect(x1, groundY - 20, x2 - x1, 20)
}

function drawMan(ctx, x, y, ph) {
  if (ph === 'falling') {
    // 掉落时旋转
    ctx.save()
    ctx.translate(x + 10, y + 20)
    ctx.rotate(state.falling * 0.1)
    ctx.translate(-10, -20)
  }

  // 身体
  ctx.fillStyle = '#FF7043'
  ctx.fillRect(x + 6, y - 15, 10, 18)
  // 头
  ctx.fillStyle = '#FFCC80'
  ctx.beginPath()
  ctx.arc(x + 11, y - 22, 9, 0, Math.PI * 2)
  ctx.fill()
  // 眼睛
  ctx.fillStyle = '#333'
  ctx.beginPath()
  ctx.arc(x + 8, y - 24, 1.5, 0, Math.PI * 2)
  ctx.fill()
  ctx.beginPath()
  ctx.arc(x + 14, y - 24, 1.5, 0, Math.PI * 2)
  ctx.fill()
  // 腿
  ctx.strokeStyle = '#5D4037'
  ctx.lineWidth = 3
  if (ph === 'walking' || ph === 'success') {
    const step = Math.sin(state.walkProgress * 0.3) * 4
    ctx.beginPath(); ctx.moveTo(x + 6, y + 3); ctx.lineTo(x + 2, y + 14 + step)
    ctx.stroke()
    ctx.beginPath(); ctx.moveTo(x + 16, y + 3); ctx.lineTo(x + 20, y + 14 - step)
    ctx.stroke()
  } else {
    ctx.beginPath(); ctx.moveTo(x + 6, y + 3); ctx.lineTo(x + 3, y + 14)
    ctx.stroke()
    ctx.beginPath(); ctx.moveTo(x + 16, y + 3); ctx.lineTo(x + 19, y + 14)
    ctx.stroke()
  }

  if (ph === 'falling') ctx.restore()
}

// ── 游戏循环 ──
function gameLoop() {
  const c = canvas.value
  if (!c) return
  const ctx = c.getContext('2d')

  if (state.phase === 'stretching') {
    // 桥在增长，由 setInterval 控制 bridgeLen
  } else if (state.phase === 'walking') {
    state.walkProgress += 2
    state.manX = state.platform1 + state.walkProgress
    // 检查小人是否到达桥末端
    const bridgeReachX = state.platform1 + state.bridgeLen
    if (state.manX >= bridgeReachX) {
      // 桥是否够到平台2
      if (state.bridgeLen >= state.gapWidth - 5 && state.bridgeLen <= state.gapWidth + 25) {
        // 正好到达 — 成功
        state.phase = 'success'
      } else {
        // 桥太长或太短 — 掉落
        state.phase = 'falling'
      }
    }
  } else if (state.phase === 'falling') {
    state.falling += 2
    state.manY += 3
    if (state.manY > H + 50) {
      state.phase = 'gameover'
      if (state.score > state.best) {
        state.best = state.score
        localStorage.setItem('bridgeBest', state.best)
        bestScore.value = state.best
      }
      gameOver.value = true
    }
  } else if (state.phase === 'success') {
    // 短暂停留后进入下一关
    setTimeout(() => nextLevel(), 600)
    state.phase = 'idle'
  }

  drawScene(ctx)

  if (state.phase !== 'gameover' && state.phase !== 'idle') {
    animId = requestAnimationFrame(gameLoop)
  } else if (state.phase === 'gameover') {
    drawScene(ctx)
    // 绘制游戏结束文字
    ctx.fillStyle = 'rgba(0,0,0,0.5)'
    ctx.fillRect(0, 0, W, H)
    ctx.fillStyle = '#FFF'
    ctx.font = 'bold 36px sans-serif'
    ctx.textAlign = 'center'
    ctx.fillText('游戏结束', W / 2, H / 2 - 10)
    ctx.font = '18px sans-serif'
    ctx.fillText(`得分: ${state.score}`, W / 2, H / 2 + 30)
  }
}

// ── 开始伸长 ──
function startStretch() {
  if (state.phase !== 'waiting') return
  state.phase = 'stretching'
  state.bridgeLen = 0
  stretchInterval = setInterval(() => {
    state.bridgeLen += 3
    if (state.bridgeLen >= state.maxBridgeLen) {
      clearInterval(stretchInterval)
    }
  }, 16)
  animId = requestAnimationFrame(gameLoop)
}

function openReply() {
  if (!evaluation.value) return
  replyForm.evaluationId = evaluation.value.id
  replyForm.reply = evaluation.value.reply || ''
  replyVisible.value = true
}

async function submitReply() {
  if (!replyForm.reply.trim()) {
    ElMessage.warning('请输入回复内容')
    return
  }
  replyLoading.value = true
  try {
    await replyEvaluation({ evaluationId: replyForm.evaluationId, reply: replyForm.reply })
    ElMessage.success('回复成功')
    replyVisible.value = false
    try {
      const eRes = await getEvaluationByRepairId(detail.value.id)
      evaluation.value = eRes.data
    } catch {}
  } catch {} finally { replyLoading.value = false }
}

onMounted(fetchData)
</script>

<template>
  <div>
    <el-card>
      <template #header><h2>历史工单</h2></template>
      <div class="filter-bar">
        <el-select v-model="query.status" placeholder="状态筛选" clearable style="width:120px" @change="() => { query.page = 1; fetchData() }">
          <el-option v-for="o in statusOptions" :key="o.value" :label="o.label" :value="o.value" />
        </el-select>
        <el-input v-model="query.title" placeholder="搜索标题" clearable style="width:180px" @clear="() => { query.page = 1; fetchData() }" />
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
      <el-table :data="rows" v-loading="loading" border stripe>
        <el-table-column prop="id" label="编号" width="80" />
        <el-table-column prop="title" label="标题" min-width="150" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }"><StatusTag :status="row.status" /></template>
        </el-table-column>
        <el-table-column prop="address" label="地址" width="150" />
        <el-table-column label="评分" width="120">
          <template #default="{ row }">
            <StarRating v-if="row.evaluationScore" :model-value="row.evaluationScore" :size="14" />
            <span v-else style="color:#94A3B8">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="170" />
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" @click="showDetail(row)">查看</el-button>
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
  </div>
</template>

<style scoped>
h2 { margin:0; font-size:20px; color:#1E293B; }
.filter-bar { display:flex; gap:10px; margin-bottom:16px; flex-wrap:wrap; }
.pagination-wrap { margin-top:16px; display:flex; justify-content:flex-start; }
.eval-box { display:flex; flex-direction:column; gap:8px; }
.eval-content { color:#475569; font-size:14px; line-height:1.6; }
.reply-box { background:#F0FDF4; border:1px solid #BBF7D0; border-radius:6px; padding:10px 12px; margin-top:4px; font-size:13px; }
.reply-label { color:#16A34A; font-weight:600; }
.reply-time { display:block; color:#94A3B8; font-size:12px; margin-top:4px; }
</style>
