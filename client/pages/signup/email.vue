<template>
  <div>
    <!-- フォーム -->
    <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 border border-orange-100">
      <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6 text-center">
        新規登録
      </h2>

      <form @submit.prevent="handleSubmit" class="space-y-6">
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
            placeholder="example@email.com"
            class="w-full px-4 py-4 text-base rounded-lg border transition-all duration-200 outline-none touch-manipulation"
            :class="emailError ? 'border-red-300 focus:ring-2 focus:ring-red-400 focus:border-transparent' : 'border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent'"
            :disabled="loading"
            @blur="validateEmail"
          />
          <!-- エラーメッセージ -->
          <p v-if="emailError" class="mt-2 text-sm text-red-600">
            {{ emailError }}
          </p>
        </div>

        <!-- エラーメッセージ（API側） -->
        <div
          v-if="apiError"
          class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm"
        >
          {{ apiError }}
        </div>

        <!-- 送信ボタン -->
        <button
          type="submit"
          :disabled="loading || !!emailError"
          class="w-full min-h-[56px] bg-gradient-to-r from-orange-400 to-pink-400 text-white font-semibold text-base py-4 px-6 rounded-lg shadow-lg active:shadow-md active:scale-[0.98] transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed disabled:active:scale-100 touch-manipulation"
        >
          <span v-if="loading" class="flex items-center justify-center">
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
            送信中...
          </span>
          <span v-else>確認メールを送信</span>
        </button>
      </form>

      <!-- ログインリンク -->
      <div class="mt-6 text-center">
        <p class="text-sm text-gray-600">
          既にアカウントをお持ちですか？
          <NuxtLink
            to="/login"
            class="text-orange-500 hover:text-orange-600 font-medium transition-colors"
          >
            ログイン
          </NuxtLink>
        </p>
      </div>

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
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'auth',
})

const router = useRouter()
const { apiFetch } = useApi()

const email = ref('')
const emailError = ref<string | null>(null)
const apiError = ref<string | null>(null)
const loading = ref(false)

// メールアドレスの簡易バリデーション
const validateEmail = () => {
  emailError.value = null

  if (!email.value.trim()) {
    emailError.value = 'メールアドレスを入力してください'
    return false
  }

  // 簡易的なメールアドレス形式チェック
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(email.value.trim())) {
    emailError.value = '有効なメールアドレスを入力してください'
    return false
  }

  return true
}

const handleSubmit = async () => {
  emailError.value = null
  apiError.value = null

  // 画面側バリデーション
  if (!validateEmail()) {
    return
  }

  loading.value = true

  try {
    const { data, error } = await apiFetch<{ message: string }>('/api/v1/signup/email', {
      method: 'POST',
      body: {
        email: email.value.trim(),
      },
    })

    if (error.value) {
      const errorData = error.value.data as any
      if (errorData?.error) {
        apiError.value = errorData.error
      } else if (errorData?.errors?.email) {
        apiError.value = Array.isArray(errorData.errors.email)
          ? errorData.errors.email[0]
          : errorData.errors.email
      } else {
        apiError.value = '確認メールの送信に失敗しました'
      }
      return
    }

    if (data.value) {
      // 成功時は送信完了画面へ遷移
      router.push('/signup/email_sent')
    }
  } catch (err: any) {
    apiError.value = err.message || '確認メールの送信に失敗しました'
  } finally {
    loading.value = false
  }
}
</script>

