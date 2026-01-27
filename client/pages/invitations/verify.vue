<template>
  <div>
    <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 border border-orange-100">
      <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6 text-center">
        招待リンクを確認中
      </h2>

      <!-- ローディング表示 -->
      <LoadingState v-if="loading">
        招待情報を確認しています...
      </LoadingState>

      <!-- 認証結果 -->
      <div v-else>
        <!-- エラー表示 -->
        <ErrorAlert v-if="errorMessage">
          {{ errorMessage }}
        </ErrorAlert>

        <!-- 成功表示 -->
        <SuccessState v-else>
          <template #title>
            招待リンクの確認が完了しました
          </template>
          <template #description>
            家族「{{ familyName }}」への参加手続きに進みます...
          </template>
        </SuccessState>

        <div class="mt-6 text-center">
          <NuxtLink to="/login" class="text-sm text-orange-600 hover:underline">
            ログイン画面に戻る
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import LoadingState from '@/components/atoms/feedback/LoadingState.vue'
import ErrorAlert from '@/components/atoms/feedback/ErrorAlert.vue'
import SuccessState from '@/components/atoms/feedback/SuccessState.vue'

definePageMeta({
  layout: 'auth',
})

const route = useRoute()
const router = useRouter()
const { apiFetchAction } = useApi()

const loading = ref(true)
const errorMessage = ref<string | null>(null)
const familyName = ref<string>('')

const token = computed(() => {
  const t = route.query.token
  return Array.isArray(t) ? (t[0] || '') : (t?.toString() || '')
})

const verifyInvitation = async () => {
  loading.value = true
  errorMessage.value = null

  if (!token.value) {
    loading.value = false
    errorMessage.value = 'トークンが指定されていません'
    return
  }

  const { data, error } = await apiFetchAction<{
    email: string
    family: { id: number; name: string }
    inviter: { id: number; name: string }
    invited: boolean
  }>('/api/v1/invitations/verify', {
    method: 'GET',
    query: { token: token.value },
  })

  if (error.value) {
    loading.value = false
    const errorData = error.value.data as any
    errorMessage.value = errorData?.error || 'このリンクは無効か、有効期限が切れています'
    return
  }

  const invitation = data.value
  if (!invitation || !invitation.family || !invitation.email) {
    loading.value = false
    errorMessage.value = '招待情報が取得できませんでした'
    return
  }

  // 後続の招待完了画面で利用できるように、最小限の情報をセッションストレージに保存
  if (process.client) {
    sessionStorage.setItem('invitation_token', token.value)
    sessionStorage.setItem('invitation_email', invitation.email)
    sessionStorage.setItem('invitation_family_name', invitation.family.name)
    sessionStorage.setItem('invitation_inviter_name', invitation.inviter.name)
  }

  familyName.value = invitation.family.name
  loading.value = false

  // 成功表示が一瞬にならないよう少し待ってから招待完了画面へ遷移（後で画面を実装）
  setTimeout(() => {
    router.replace('/invitations/complete')
  }, 2400)
}

onMounted(() => {
  verifyInvitation()
})
</script>


