<template>
  <div class="flex items-center space-x-2">
    <div
      :class="[
        'inline-flex items-center justify-center rounded-full bg-gradient-to-br from-orange-400 to-pink-400',
        circleSizeClass,
      ]"
    >
      <svg
        :class="['text-white', iconSizeClass]"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
        />
      </svg>
    </div>
    <span :class="textClass">
      FamilyOps
    </span>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(
  defineProps<{
    compact?: boolean
  }>(),
  {
    compact: false,
  }
)

const circleSizeClass = computed(() =>
  props.compact ? 'w-8 h-8' : 'w-10 h-10'
)

const iconSizeClass = computed(() =>
  props.compact ? 'w-5 h-5' : 'w-6 h-6'
)

const textClass = computed(() =>
  props.compact
    ? 'text-sm font-semibold text-gray-800'
    : 'text-xl font-bold text-gray-800'
)
</script>


