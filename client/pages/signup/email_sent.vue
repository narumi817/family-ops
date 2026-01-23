<template>
  <NuxtLayout name="auth">
    <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 border border-orange-100">
      <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6 text-center">
        確認メールを送信しました
      </h2>

      <!-- メインコンテンツ -->
      <div class="space-y-6">
        <!-- アイコンとメッセージ -->
        <div class="text-center">
          <div class="inline-flex items-center justify-center w-16 h-16 sm:w-20 sm:h-20 bg-gradient-to-br from-orange-100 to-pink-100 rounded-full mb-4">
            <svg
              class="w-8 h-8 sm:w-10 sm:h-10 text-orange-500"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
              />
            </svg>
          </div>
          <p class="text-base sm:text-lg text-gray-700 mb-2">
            メールボックスを確認してください
          </p>
          <p class="text-sm text-gray-600">
            確認メールに記載されているリンクをクリックして、登録を完了してください。
          </p>
        </div>

        <!-- 案内メッセージ -->
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div class="flex items-start">
            <svg
              class="w-5 h-5 text-blue-500 mt-0.5 mr-3 flex-shrink-0"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
            <div class="text-sm text-blue-800">
              <p class="font-medium mb-1">メールが届かない場合</p>
              <ul class="list-disc list-inside space-y-1 text-blue-700">
                <li>迷惑メールフォルダを確認してください</li>
                <li>メールアドレスが正しいか確認してください</li>
                <li>数分待ってから再度お試しください</li>
              </ul>
            </div>
          </div>
        </div>

        <!-- アクションボタン -->
        <div class="space-y-3">
          <button
            type="button"
            :disabled="loading"
            @click="handleResend"
            class="w-full min-h-[48px] bg-white border-2 border-orange-400 text-orange-600 font-semibold text-base py-3 px-6 rounded-lg hover:bg-orange-50 active:scale-[0.98] transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed disabled:active:scale-100 touch-manipulation"
          >
            <span v-if="loading" class="flex items-center justify-center">
              <svg
                class="animate-spin -ml-1 mr-3 h-5 w-5 text-orange-600"
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
            <span v-else>メールを再送信</span>
          </button>

          <NuxtLink
            to="/signup/email"
            class="block w-full text-center text-sm text-gray-600 hover:text-orange-600 transition-colors"
          >
            メールアドレスを変更する
          </NuxtLink>
        </div>

        <!-- エラーメッセージ（再送信時） -->
        <div
          v-if="apiError"
          class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm"
        >
          {{ apiError }}
        </div>

        <!-- 成功メッセージ（再送信時） -->
        <div
          v-if="successMessage"
          class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg text-sm"
        >
          {{ successMessage }}
        </div>
      </div>

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
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false, // layouts/auth.vue を使用するため、ページ自身のレイアウトは無効化
})

const router = useRouter()
const { apiFetchAction } = useApi()

const loading = ref(false)
const apiError = ref<string | null>(null)
const successMessage = ref<string | null>(null)

// セッションストレージからメールアドレスを取得（再送信用）
const getEmailFromSession = (): string | null => {
  if (process.client) {
    return sessionStorage.getItem('signup_email')
  }
  return null
}

// メール再送信処理
const handleResend = async () => {
  const email = getEmailFromSession()
  
  if (!email) {
    // セッションストレージにメールアドレスがない場合は、メール入力画面に戻る
    router.push('/signup/email')
    return
  }

  loading.value = true
  apiError.value = null
  successMessage.value = null

  try {
    const { data, error } = await apiFetchAction<{ message: string }>('/api/v1/signup/email', {
      method: 'POST',
      body: {
        email: email,
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
        apiError.value = '確認メールの再送信に失敗しました'
      }
      return
    }

    if (data.value) {
      successMessage.value = '確認メールを再送信しました。メールボックスを確認してください。'
      // 3秒後に成功メッセージを非表示
      setTimeout(() => {
        successMessage.value = null
      }, 3000)
    }
  } catch (err: any) {
    apiError.value = err.message || '確認メールの再送信に失敗しました'
  } finally {
    loading.value = false
  }
}
</script>

