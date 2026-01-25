<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-pink-50 to-yellow-50">
    <div class="container mx-auto px-4 py-8">
      <!-- ローディング中 -->
      <div v-if="checkingAuth" class="flex items-center justify-center min-h-[400px]">
        <div class="text-center">
          <div class="inline-flex items-center justify-center w-16 h-16 bg-orange-50 rounded-full mb-4">
            <svg
              class="animate-spin h-8 w-8 text-orange-500"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle
                class="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                stroke-width="4"
              />
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              />
            </svg>
          </div>
          <p class="text-sm text-gray-600">読み込み中...</p>
        </div>
      </div>

      <!-- 認証状態確認完了後 -->
      <template v-else>
        <!-- ヘッダー -->
        <header class="flex justify-between items-center mb-6 sm:mb-8">
          <h1 class="text-2xl sm:text-3xl font-bold text-gray-800">FamilyOps</h1>
          <button
            v-if="authStore.loggedIn"
            @click="handleLogout"
            class="min-h-[48px] px-4 sm:px-6 py-3 bg-white rounded-lg shadow-md active:shadow-sm active:scale-[0.98] transition-all duration-200 text-gray-700 text-sm sm:text-base font-medium touch-manipulation"
          >
            ログアウト
          </button>
          <NuxtLink
            v-else
            to="/login"
            class="min-h-[48px] px-4 sm:px-6 py-3 bg-gradient-to-r from-orange-400 to-pink-400 text-white rounded-lg shadow-md active:shadow-sm active:scale-[0.98] transition-all duration-200 text-sm sm:text-base font-medium touch-manipulation inline-flex items-center justify-center"
          >
            ログイン
          </NuxtLink>
        </header>

        <!-- メインコンテンツ -->
        <div v-if="authStore.loggedIn" class="bg-white rounded-2xl shadow-xl p-6 sm:p-8">
          <div class="text-center mb-6">
            <div class="inline-flex items-center justify-center w-16 h-16 sm:w-20 sm:h-20 bg-gradient-to-br from-orange-400 to-pink-400 rounded-full mb-4">
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
                  d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                />
              </svg>
            </div>
            <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-2">
              ようこそ、{{ authStore.user?.name }}さん！
            </h2>
            <p class="text-sm sm:text-base text-gray-600">{{ authStore.user?.email }}</p>
          </div>
        </div>

        <div v-else class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 text-center">
          <p class="text-sm sm:text-base text-gray-600 mb-6">ログインして、家族の毎日を記録しましょう</p>
          <NuxtLink
            to="/login"
            class="inline-flex items-center justify-center min-h-[56px] px-6 py-4 bg-gradient-to-r from-orange-400 to-pink-400 text-white rounded-lg shadow-md active:shadow-sm active:scale-[0.98] transition-all duration-200 text-base font-semibold touch-manipulation"
          >
            ログイン画面へ
          </NuxtLink>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
const authStore = useAuthStore()
const router = useRouter()

const checkingAuth = ref(true)

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}

// ページ読み込み時にログイン状態を確認
onMounted(async () => {
  await authStore.checkLoginStatus()
  checkingAuth.value = false
})
</script>
