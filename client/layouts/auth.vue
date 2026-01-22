<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-pink-50 to-yellow-50 flex items-center justify-center p-4 sm:p-6">
    <div class="w-full max-w-md">
      <!-- ロゴ・タイトル -->
      <div class="text-center mb-6 sm:mb-8">
        <div class="inline-flex items-center justify-center w-16 h-16 sm:w-20 sm:h-20 bg-gradient-to-br from-orange-400 to-pink-400 rounded-full shadow-lg mb-3 sm:mb-4">
          <svg
            class="w-10 h-10 sm:w-12 sm:h-12 text-white"
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
        <h1 class="text-3xl sm:text-4xl font-bold text-gray-800 mb-2">FamilyOps</h1>
        <p class="text-sm sm:text-base text-gray-600">家族の毎日を、もっと楽しく</p>
      </div>

      <!-- コンテンツ -->
      <slot />

      <!-- フッター -->
      <div class="mt-6 text-center text-xs sm:text-sm text-gray-500">
        <p>© 2024 FamilyOps. すべての家族に、笑顔を。</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 認証前の共通レイアウト
// ログイン画面、サインアップ画面で使用
</script>

