<template>
  <div class="text-center">
    <div class="inline-flex items-center justify-center w-16 h-16 bg-green-50 rounded-full mb-4">
      <svg
        class="h-8 w-8 text-green-600"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M5 13l4 4L19 7"
        />
      </svg>
    </div>
    <p class="text-sm text-gray-700 mb-2">
      <slot name="title">処理が完了しました</slot>
    </p>
    <p class="text-xs text-gray-500">
      <slot name="description"></slot>
    </p>
  </div>
</template>

<script setup lang="ts">
// atoms: 成功時のアイコン + メッセージ表示
</script>

