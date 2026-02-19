<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-pink-50 to-yellow-50">
    <!-- ヘッダーナビゲーション -->
    <header class="bg-white shadow-md border-b border-orange-100">
      <div class="container mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <!-- ロゴ -->
          <NuxtLink to="/" class="flex items-center space-x-2">
            <BrandLogo />
          </NuxtLink>

        <!-- ナビゲーションメニュー -->
        <nav class="flex items-center space-x-[2px] sm:space-x-2">
            <NuxtLink
              to="/"
              class="rounded-full px-3 py-1 text-xs font-medium text-gray-600 ring-1 ring-gray-200 hover:bg-gray-50 transition-colors sm:text-sm"
            >
              ダッシュボード
            </NuxtLink>
            <NuxtLink
              v-if="authStore.family"
              :to="`/families/${authStore.family.id}/invitations/new`"
              class="rounded-full px-3 py-1 text-xs font-semibold text-orange-600 ring-2 ring-orange-300/70 hover:bg-orange-50 transition-colors sm:text-sm"
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
            <!-- 使い方ヘルプ -->
            <button
              type="button"
              class="inline-flex h-8 w-8 items-center justify-center rounded-full border border-gray-200 text-xs font-semibold text-gray-500 hover:border-orange-300 hover:text-orange-500"
              @click="showHelp = true"
            >
              ?
            </button>
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

    <!-- 使い方モーダル -->
    <HelpGuideModal v-if="showHelp" @close="showHelp = false" />
  </div>
</template>

<script setup lang="ts">
import HelpGuideModal from '~/components/organisms/HelpGuideModal.vue'
import BrandLogo from '~/components/atoms/BrandLogo.vue'

const authStore = useAuthStore()
const router = useRouter()

const showHelp = ref(false)

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

