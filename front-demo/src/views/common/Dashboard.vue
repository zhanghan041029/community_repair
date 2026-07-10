<script setup>
import { useUserStore } from '@/store/user'
import ResidentDashboard from '@/views/resident/ResidentDashboard.vue'
import WorkerDashboard from '@/views/worker/RepairDashboard.vue'
import AdminDashboard from '@/views/admin/AdminDashboard.vue'
import { computed } from 'vue'

const userStore = useUserStore()

const component = computed(() => {
  if (!userStore.role) return null
  if (userStore.role === 'worker') return WorkerDashboard
  if (userStore.role === 'admin') return AdminDashboard
  return ResidentDashboard
})
</script>

<template>
  <component :is="component" />
</template>