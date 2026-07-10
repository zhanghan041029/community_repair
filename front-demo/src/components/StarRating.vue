<script setup>
import { computed } from 'vue'
import { Star, StarFilled } from '@element-plus/icons-vue'

const props = defineProps({
  modelValue: { type: Number, default: 0 },
  editable: { type: Boolean, default: false },
  size: { type: [Number, String], default: 18 }
})
const emit = defineEmits(['update:modelValue'])

const stars = computed(() =>
  Array.from({ length: 5 }, (_, i) => i < props.modelValue)
)

function setRating(n) {
  if (props.editable) emit('update:modelValue', n + 1)
}
</script>

<template>
  <span class="star-rating">
    <span
      v-for="(filled, i) in stars"
      :key="i"
      :class="{ clickable: editable, active: filled }"
      @click="setRating(i)"
    >
      <el-icon :size="size">
        <StarFilled v-if="filled" color="#F59E0B" />
        <Star v-else color="#CBD5E1" />
      </el-icon>
    </span>
  </span>
</template>

<style scoped>
.star-rating { display: inline-flex; gap: 2px; }
.clickable { cursor: pointer; }
</style>