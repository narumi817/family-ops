<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-pink-50 to-yellow-50">
    <!-- ヘッダーナビゲーション -->
    <header class="bg-white shadow-md border-b border-orange-100">
      <div class="container mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <!-- ロゴ -->
          <NuxtLink to="/" class="flex items-center space-x-2">
            <div class="inline-flex items-center justify-center w-10 h-10 bg-gradient-to-br from-orange-400 to-pink-400 rounded-full">
              <svg
                class="w-6 h-6 text-white"
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
            <h1 class="text-xl font-bold text-gray-800">FamilyOps</h1>
          </NuxtLink>

          <!-- ナビゲーションメニュー -->
          <nav class="flex items-center space-x-4">
            <NuxtLink
              to="/"
              class="px-3 py-2 text-sm font-medium text-gray-700 hover:text-orange-500 transition-colors"
            >
              ダッシュボード
            </NuxtLink>
            <NuxtLink
              v-if="authStore.family"
              :to="`/families/${authStore.family.id}/invitations/new`"
              class="px-3 py-2 text-sm font-medium text-gray-700 hover:text-orange-500 transition-colors"
            >
              家族を招待
            </NuxtLink>
            <!-- 将来実装: 家族一覧 -->
            <!-- <NuxtLink
              to="/families"
              class="px-3 py-2 text-sm font-medium text-gray-700 hover:text-orange-500 transition-colors"
            >
              家族一覧
            </NuxtLink> -->
            <!-- 将来実装: ログ投稿 -->
            <!-- <NuxtLink
              to="/logs/new"
              class="px-3 py-2 text-sm font-medium text-gray-700 hover:text-orange-500 transition-colors"
            >
              ログ投稿
            </NuxtLink> -->
            <button
              @click="handleLogout"
              class="px-3 py-2 text-sm font-medium text-gray-700 hover:text-orange-500 transition-colors"
            >
              ログアウト
            </button>
          </nav>
        </div>
      </div>
    </header>

    <!-- メインコンテンツ -->
    <main class="container mx-auto px-4 py-8">
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
const authStore = useAuthStore()
const router = useRouter()

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}

// 認証チェック
onMounted(async () => {
  await authStore.checkLoginStatus()
  if (!authStore.loggedIn) {
    router.push('/login')
  }
})
</script>

