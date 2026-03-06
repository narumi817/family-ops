<template>
  <div>
    <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 border border-orange-100">
      <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-4 text-center">
        パスワードをお忘れの方へ
      </h2>
      <p class="text-sm text-gray-600 mb-6 text-center">
        登録済みのメールアドレスを入力すると、パスワード再設定用のリンクをお送りします。
      </p>

      <form v-if="!sent" @submit.prevent="handleSubmit" class="space-y-6">
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
            class="w-full px-4 py-3 text-base rounded-lg border border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all duration-200 outline-none touch-manipulation"
            :disabled="submitting"
          />
        </div>

        <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
          {{ error }}
        </div>

        <button
          type="submit"
          :disabled="submitting"
          class="w-full min-h-[52px] bg-gradient-to-r from-orange-400 to-pink-400 text-white font-semibold text-base py-3 px-6 rounded-lg shadow-lg active:shadow-md active:scale-[0.98] transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed disabled:active:scale-100 touch-manipulation"
        >
          <span v-if="submitting" class="flex items-center justify-center">
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
          <span v-else>リセット用リンクを送信する</span>
        </button>
      </form>

      <div
        v-else-if="successMessage"
        class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg text-sm whitespace-pre-line"
      >
        {{ successMessage }}
      </div>

      <div class="mt-6 text-center">
        <NuxtLink
          to="/login"
          class="text-sm text-gray-600 hover:text-orange-500 transition-colors"
        >
          ログイン画面に戻る
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'auth',
})

const { apiFetchAction } = useApi()

const email = ref('')
const submitting = ref(false)
const error = ref<string | null>(null)
const successMessage = ref<string | null>(null)
const sent = ref(false)

const handleSubmit = async () => {
  error.value = null
  successMessage.value = null

  if (!email.value) {
    error.value = 'メールアドレスを入力してください'
    return
  }

  submitting.value = true

  const { error: apiError } = await apiFetchAction<{ message: string }>('/api/v1/password_reset', {
    method: 'POST',
    body: {
      email: email.value,
    },
  })

  submitting.value = false

  // セキュリティの観点から、成功・失敗にかかわらず同じメッセージを表示する
  if (apiError.value && apiError.value.statusCode === 400) {
    // クライアント側のメール形式が明らかに不正などの場合のみエラー表示してもよいが、
    // ここではAPIエラーも「送信完了」扱いにする
    console.info('Password reset request error', apiError.value)
  }

  successMessage.value = '入力されたメールアドレス宛てに、パスワード再設定用のリンクを送信しました。\n\n' +
    'メールが届かない場合は、メールアドレスをご確認のうえ、再度お試しください。'
  sent.value = true
}
</script>

