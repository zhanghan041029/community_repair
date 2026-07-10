<script setup>
import { ref, watch } from 'vue'
import { getRepairDetail } from '@/api/repair'
import { getEvaluationByRepairId } from '@/api/evaluation'
import StatusTag from '@/components/StatusTag.vue'
import StarRating from '@/components/StarRating.vue'

const props = defineProps({
  visible: Boolean,
  repairId: [Number, String]
})
const emit = defineEmits(['update:visible', 'refresh'])
const loading = ref(false)
const detail = ref(null)
const evaluation = ref(null)

watch(() => props.visible, async (val) => {
  if (val && props.repairId) {
    loading.value = true
    try {
      const dRes = await getRepairDetail(props.repairId)
      detail.value = dRes.data
      if (detail.value?.status === 'completed') {
        try {
          const eRes = await getEvaluationByRepairId(props.repairId)
          evaluation.value = eRes.data
        } catch { evaluation.value = null }
      } else {
        evaluation.value = null
      }
    } finally {
      loading.value = false
    }
  }
})

function handleClose() {
  emit('update:visible', false)
  detail.value = null
  evaluation.value = null
}
</script>

<template>
  <el-dialog
    :model-value="visible"
    title="工单详情"
    width="600px"
    @update:model-value="handleClose"
  >
    <div v-loading="loading">
      <template v-if="detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="工单编号">{{ detail.id }}</el-descriptions-item>
          <el-descriptions-item label="状态"><StatusTag :status="detail.status" /></el-descriptions-item>
          <el-descriptions-item label="标题">
            {{ detail.title }}
            <el-tag v-if="detail.priority === 'urgent'" type="danger" size="small" style="margin-left:8px">紧急</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="联系人">{{ detail.userName }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ detail.contactPhone }}</el-descriptions-item>
          <el-descriptions-item label="地址">{{ detail.address }}</el-descriptions-item>
          <el-descriptions-item label="故障描述" :span="2">{{ detail.description }}</el-descriptions-item>
          <el-descriptions-item v-if="detail.image" label="现场照片" :span="2">
            <el-image
              :src="'http://localhost:8080/api' + detail.image"
              fit="cover"
              style="width:100%;max-width:400px;border-radius:8px;"
              :preview-src-list="['http://localhost:8080/api' + detail.image]"
              preview-teleported
            />
          </el-descriptions-item>
          <el-descriptions-item v-if="detail.workerName" label="维修师傅" :span="2">
            <el-avatar :size="36" :src="detail.workerAvatar" />
            {{ detail.workerName }}
          </el-descriptions-item>
          <el-descriptions-item v-if="detail.result" label="维修结果" :span="2">{{ detail.result }}</el-descriptions-item>
        </el-descriptions>
        <div v-if="evaluation" class="eval-section">
          <el-divider>评价信息</el-divider>
          <div class="eval-content">
            <StarRating :model-value="evaluation.score" />
            <span class="eval-score">{{ evaluation.score }}分</span>
          </div>
          <p class="eval-comment">{{ evaluation.comment }}</p>
          <p class="eval-user">评价人: {{ evaluation.userName }}</p>
          <div v-if="evaluation.reply" class="reply-box">
            <span class="reply-label">维修工回复：</span>
            <span>{{ evaluation.reply }}</span>
            <span class="reply-time">{{ evaluation.replyTime }}</span>
          </div>
        </div>
      </template>
    </div>
  </el-dialog>
</template>

<style scoped>
.eval-section { margin-top: 16px; }
.eval-content { display: flex; align-items: center; gap: 8px; }
.eval-score { color: #F59E0B; font-weight: 600; }
.eval-comment { color: #475569; margin: 8px 0; }
.eval-user { color: #94A3B8; font-size: 12px; }
.reply-box { background:#F0FDF4; border:1px solid #BBF7D0; border-radius:6px; padding:10px 12px; margin-top:8px; font-size:13px; }
.reply-label { color:#16A34A; font-weight:600; }
.reply-time { display:block; color:#94A3B8; font-size:12px; margin-top:4px; }
</style>