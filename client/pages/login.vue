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

      <!-- ログインフォーム -->
      <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 border border-orange-100">
        <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6 text-center">
          ログイン
        </h2>

        <form @submit.prevent="handleLogin" class="space-y-6">
          <!-- メールアドレス -->
          <div>
            <label
              for="email"
              class="block text-sm font-medium text-gray-700 mb-2"
            >
              メールアドレス
            </label>
            <input
              id="email"
              v-model="email"
              type="email"
              required
              placeholder="example@email.com"
              class="w-full px-4 py-4 text-base rounded-lg border border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all duration-200 outline-none touch-manipulation"
              :disabled="authStore.loading"
            />
          </div>

          <!-- パスワード -->
          <div>
            <label
              for="password"
              class="block text-sm font-medium text-gray-700 mb-2"
            >
              パスワード
            </label>
            <input
              id="password"
              v-model="password"
              type="password"
              required
              placeholder="••••••••"
              class="w-full px-4 py-4 text-base rounded-lg border border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all duration-200 outline-none touch-manipulation"
              :disabled="authStore.loading"
            />
          </div>

          <!-- エラーメッセージ -->
          <div
            v-if="error"
            class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm"
          >
            {{ error }}
          </div>

          <!-- ログインボタン -->
          <button
            type="submit"
            :disabled="authStore.loading"
            class="w-full min-h-[56px] bg-gradient-to-r from-orange-400 to-pink-400 text-white font-semibold text-base py-4 px-6 rounded-lg shadow-lg active:shadow-md active:scale-[0.98] transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed disabled:active:scale-100 touch-manipulation"
          >
            <span v-if="authStore.loading" class="flex items-center justify-center">
              <svg
                class="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
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
              ログイン中...
            </span>
            <span v-else>ログイン</span>
          </button>
        </form>

        <!-- デコレーション -->
        <div class="mt-6 text-center">
          <div class="inline-flex items-center space-x-2 text-xs sm:text-sm text-gray-500">
            <svg
              class="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
              />
            </svg>
            <span>安全に保護されています</span>
          </div>
        </div>
      </div>

      <!-- フッター -->
      <div class="mt-6 text-center text-xs sm:text-sm text-gray-500">
        <p>© 2024 FamilyOps. すべての家族に、笑顔を。</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false,
})

const authStore = useAuthStore()
const router = useRouter()

const email = ref('')
const password = ref('')
const error = ref<string | null>(null)

const handleLogin = async () => {
  error.value = null

  const result = await authStore.login(email.value, password.value)

  if (result.success) {
    // ログイン成功時はホーム画面にリダイレクト
    router.push('/')
  } else {
    error.value = result.error || 'ログインに失敗しました'
  }
}

// 既にログインしている場合はホームにリダイレクト
onMounted(async () => {
  await authStore.checkLoginStatus()
  if (authStore.loggedIn) {
    router.push('/')
  }
})
</script>

