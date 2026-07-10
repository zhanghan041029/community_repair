<script setup>
import { useUserStore } from '@/store/user'
import { watch } from 'vue'

const userStore = useUserStore()
watch(() => userStore.token, (val) => {
  if (val) userStore.fetchCurrentUser()
}, { immediate: true })
</script>

<template>
  <router-view />
</template>