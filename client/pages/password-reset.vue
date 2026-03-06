<template>
  <div>
    <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 border border-orange-100">
      <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-4 text-center">
        パスワード再設定
      </h2>

      <!-- ローディング -->
      <div v-if="loading" class="flex flex-col items-center justify-center py-10 space-y-3 text-gray-600">
        <svg
          class="animate-spin h-6 w-6 text-orange-400"
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
        <p class="text-sm">リンクを確認しています...</p>
      </div>

      <!-- エラー表示（トークン不正など） -->
      <div v-else-if="errorMessage && !success" class="space-y-4">
        <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm whitespace-pre-line">
          {{ errorMessage }}
        </div>
        <div class="text-center">
          <NuxtLink
            to="/forgot-password"
            class="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-orange-500 hover:bg-orange-600 rounded-lg shadow-sm transition-colors"
          >
            パスワード再設定メールを再送する
          </NuxtLink>
        </div>
      </div>

      <!-- 成功表示 -->
      <div v-else-if="success" class="space-y-6 text-center">
        <div class="bg-green-50 border border-green-200 text-green-700 px-4 py-4 rounded-lg text-sm whitespace-pre-line">
          パスワードを更新しました。
          下記のボタンからログインしてください。
        </div>
        <NuxtLink
          to="/login"
          class="inline-flex items-center justify-center px-6 py-3 text-sm sm:text-base font-semibold text-white bg-gradient-to-r from-orange-400 to-pink-400 rounded-lg shadow-md hover:shadow-lg active:scale-[0.98] transition-all"
        >
          ログイン画面へ
        </NuxtLink>
      </div>

      <!-- パスワード再設定フォーム -->
      <form v-else @submit.prevent="handleSubmit" class="space-y-6">
        <p v-if="email" class="text-sm text-gray-600">
          <span class="font-medium">対象メールアドレス:</span>
          <span class="ml-1 break-all">{{ email }}</span>
        </p>

        <PasswordFields
          :password="password"
          :password-error="passwordError || undefined"
          :password-confirmation="passwordConfirmation"
          :password-confirmation-error="passwordConfirmationError || undefined"
          :disabled="submitting"
          @update:password="(value) => (password = value)"
          @update:passwordConfirmation="(value) => (passwordConfirmation = value)"
        />

        <div
          v-if="formError"
          class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm"
        >
          {{ formError }}
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
            更新中...
          </span>
          <span v-else>パスワードを更新する</span>
        </button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import PasswordFields from '@/components/molecules/forms/PasswordFields.vue'

definePageMeta({
  layout: 'auth',
})

const route = useRoute()
const { apiFetchAction } = useApi()

const token = ref<string | null>(null)
const email = ref<string | null>(null)
const loading = ref(true)
const errorMessage = ref<string | null>(null)
const success = ref(false)

const password = ref('')
const passwordConfirmation = ref('')
const passwordError = ref<string | null>(null)
const passwordConfirmationError = ref<string | null>(null)
const formError = ref<string | null>(null)
const submitting = ref(false)

onMounted(async () => {
  token.value = (route.query.token as string | undefined) || null

  const { data, error } = await apiFetchAction<{ email: string }>('/api/v1/password_reset/verify', {
    method: 'GET',
    params: {
      token: token.value,
    },
  })

  if (error.value) {
    const apiData = error.value.data as { error?: string } | undefined
    errorMessage.value = apiData?.error || 'このリンクは無効か、有効期限が切れています'
  } else if (data.value) {
    email.value = data.value.email
  }

  loading.value = false
})

const handleSubmit = async () => {
  if (!token.value) return

  // リセット
  passwordError.value = null
  passwordConfirmationError.value = null
  formError.value = null

  // 簡易バリデーション
  if (!password.value) {
    passwordError.value = 'パスワードを入力してください'
  }
  if (!passwordConfirmation.value) {
    passwordConfirmationError.value = 'パスワード（確認用）を入力してください'
  }
  if (!password.value || !passwordConfirmation.value) {
    return
  }
  if (password.value !== passwordConfirmation.value) {
    passwordConfirmationError.value = 'パスワード（確認用）とパスワードが一致しません'
    return
  }

  submitting.value = true

  const { error } = await apiFetchAction<{ message: string }>('/api/v1/password_reset/complete', {
    method: 'POST',
    body: {
      token: token.value,
      password: password.value,
      password_confirmation: passwordConfirmation.value,
    },
  })

  submitting.value = false

  if (error.value) {
    const apiData = error.value.data as { error?: string; errors?: Record<string, string[]> } | undefined

    if (apiData?.errors) {
      const fieldErrors = apiData.errors
      if (fieldErrors.password?.length) {
        passwordError.value = fieldErrors.password.join('、')
      }
      if (fieldErrors.password_confirmation?.length) {
        passwordConfirmationError.value = fieldErrors.password_confirmation.join('、')
      }
      if (!fieldErrors.password && !fieldErrors.password_confirmation) {
        formError.value = Object.values(fieldErrors)
          .flat()
          .join('、')
      }
    } else if (apiData?.error) {
      formError.value = apiData.error
    } else {
      formError.value = 'パスワードの更新に失敗しました。時間をおいて再度お試しください。'
    }

    return
  }

  success.value = true
}
</script>

