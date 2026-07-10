<script setup>
import { computed } from 'vue'

const props = defineProps({
  status: { type: String, required: true },
  type: { type: String, default: 'repair' }
})

const label = computed(() => {
  if (props.type === 'repair') {
    return {
      pending: '待派单', assigned: '已派单', processing: '处理中',
      completed: '已完成', cancelled: '已取消'
    }[props.status] || props.status
  }
  if (props.type === 'worker') {
    return {
      active: '正常', pending: '待审核', rejected: '已拒绝'
    }[props.status] || props.status
  }
  return props.status
})

const typeClass = computed(() => {
  if (props.type === 'repair') {
    return {
      pending: 'warning', assigned: '', processing: 'primary',
      completed: 'success', cancelled: 'info'
    }[props.status] || 'info'
  }
  return {
    active: 'success', pending: 'warning', rejected: 'danger'
  }[props.status] || 'info'
})
</script>

<template>
  <el-tag :type="typeClass" size="small">{{ label }}</el-tag>
</template>