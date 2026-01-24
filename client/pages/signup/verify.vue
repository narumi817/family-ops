<template>
  <div>
    <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 border border-orange-100">
      <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6 text-center">
        メールアドレスを確認中
      </h2>

      <div v-if="loading" class="text-center py-6">
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
        <p class="text-sm text-gray-600">認証中...</p>
      </div>

      <div v-else>
        <div
          v-if="errorMessage"
          class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm"
        >
          {{ errorMessage }}
        </div>

        <div v-else class="text-center">
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
          <p class="text-sm text-gray-700 mb-2">認証が完了しました</p>
          <p class="text-xs text-gray-500">登録画面へ移動します...</p>
        </div>

        <div class="mt-6 text-center">
          <NuxtLink to="/signup/email" class="text-sm text-orange-600 hover:underline">
            メールアドレス入力画面に戻る
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'auth',
})

const route = useRoute()
const router = useRouter()
const { apiFetchAction } = useApi()

const loading = ref(true)
const errorMessage = ref<string | null>(null)

const token = computed(() => {
  const t = route.query.token
  return Array.isArray(t) ? (t[0] || '') : (t?.toString() || '')
})

const verifyToken = async () => {
  loading.value = true
  errorMessage.value = null

  if (!token.value) {
    loading.value = false
    errorMessage.value = 'トークンが指定されていません'
    return
  }

  const { data, error } = await apiFetchAction<{ email: string; verified: boolean }>(
    '/api/v1/signup/verify',
    {
      method: 'GET',
      query: { token: token.value },
    },
  )

  if (error.value) {
    loading.value = false
    const errorData = error.value.data as any
    errorMessage.value = errorData?.error || 'このリンクは無効か、有効期限が切れています'
    return
  }

  const email = data.value?.email
  if (!email) {
    loading.value = false
    errorMessage.value = 'メールアドレスが取得できませんでした'
    return
  }

  // URLにemailを出さないため、sessionStorageに保存してcompleteへ
  sessionStorage.setItem('signup_email', email)

  loading.value = false

  // 成功表示が一瞬にならないよう少し待ってから遷移（UX）
  setTimeout(() => {
    router.replace('/signup/complete')
  }, 2400)
}

onMounted(() => {
  verifyToken()
})
</script>


