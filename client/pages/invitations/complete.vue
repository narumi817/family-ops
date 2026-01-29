<template>
  <div>
    <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 border border-orange-100">
      <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6 text-center">
        招待を受けて登録を完了する
      </h2>

      <!-- 招待情報（家族名・招待者） -->
      <div class="mb-6 space-y-2 text-sm text-gray-700">
        <p v-if="familyName">
          家族：
          <span class="font-semibold">「{{ familyName }}」</span>
        </p>
        <p v-if="inviterName">
          招待者：
          <span class="font-semibold">{{ inviterName }}</span>
          さんからの招待です
        </p>
      </div>

      <!-- メールアドレス（表示のみ） -->
      <div class="mb-6">
        <label class="block text-sm font-medium text-gray-700 mb-2">
          メールアドレス
        </label>
        <div
          class="w-full px-4 py-4 text-base rounded-lg border border-gray-200 bg-gray-50 text-gray-700"
        >
          {{ email || "（未設定）" }}
        </div>
        <p v-if="!email" class="mt-2 text-sm text-red-600">
          メールアドレスが取得できませんでした。招待メールのリンクからアクセスし直してください。
        </p>
      </div>

      <form @submit="onSubmit" class="space-y-6">
        <!-- ユーザー名 -->
        <UserNameField
          v-model="nameValue"
          :error="nameErrorToShow || undefined"
          :disabled="loading || !email || !token"
          :on-input-clear-error="() => clearApiFieldError('name')"
          :on-blur-touch="() => { nameMeta.touched = true }"
        />

        <!-- パスワード & 確認用 -->
        <PasswordFields
          :password="passwordValue"
          :password-error="passwordErrorToShow || undefined"
          :password-on-input-clear-error="() => clearApiFieldError('password')"
          :password-on-blur-touch="() => { passwordMeta.touched = true }"
          :password-confirmation="passwordConfirmationValue"
          :password-confirmation-error="passwordConfirmationErrorToShow || undefined"
          :password-confirmation-on-input-clear-error="() => clearApiFieldError('password_confirmation')"
          :password-confirmation-on-blur-touch="() => { passwordConfirmationMeta.touched = true }"
          :disabled="loading || !email || !token"
          @update:password="(value) => (passwordValue = value)"
          @update:passwordConfirmation="(value) => (passwordConfirmationValue = value)"
        />

        <!-- 役割 -->
        <FamilyRoleSelect
          v-model="roleValue"
          :error="roleErrorToShow || undefined"
          :disabled="loading || !email || !token"
          :on-change-clear-error="() => clearApiFieldError('role')"
        />

        <!-- エラーメッセージ（API側の汎用エラー） -->
        <ErrorAlert v-if="apiError">
          {{ apiError }}
        </ErrorAlert>

        <!-- 登録ボタン -->
        <button
          type="submit"
          :disabled="loading || !email || !token || !isValid"
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
            登録中...
          </span>
          <span v-else>招待を受けて登録を完了</span>
        </button>
      </form>

      <div class="mt-6 text-center">
        <NuxtLink to="/login" class="text-sm text-orange-600 hover:underline">
          ログイン画面に戻る
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useForm, useField } from 'vee-validate'
import ErrorAlert from '@/components/atoms/feedback/ErrorAlert.vue'
import UserNameField from '@/components/molecules/forms/UserNameField.vue'
import PasswordFields from '@/components/molecules/forms/PasswordFields.vue'
import FamilyRoleSelect from '@/components/molecules/forms/FamilyRoleSelect.vue'
import { useSignupValidationSchema, useFieldError } from '@/composables/useSignupValidation'
import { useMasterDataStore } from '@/stores/masterData'

definePageMeta({
  layout: 'auth',
})

type ApiFieldErrors = Record<string, string[]>

const router = useRouter()
const authStore = useAuthStore()
const { apiFetchAction } = useApi()
const masterDataStore = useMasterDataStore()

const email = ref<string>('')
const token = ref<string>('')
const familyName = ref<string>('')
const inviterName = ref<string>('')

const loading = ref(false)
const apiError = ref<string | null>(null)
const apiFieldErrors = ref<ApiFieldErrors>({})

onMounted(async () => {
  if (process.client) {
    email.value = sessionStorage.getItem('invitation_email') || ''
    token.value = sessionStorage.getItem('invitation_token') || ''
    familyName.value = sessionStorage.getItem('invitation_family_name') || ''
    inviterName.value = sessionStorage.getItem('invitation_inviter_name') || ''
  }

  // マスターデータを取得（まだ取得していない場合）
  if (!masterDataStore.loaded && !masterDataStore.loading) {
    await masterDataStore.fetchMasterData()
  }
})

// バリデーションスキーマ（マスターAPIから取得した値を使用）
const { validationSchema, initialValues } = useSignupValidationSchema({
  includeFamilyName: false,
})

// useForm の初期化（validationSchema が computed なので watch で更新）
const form = useForm({
  validationSchema: validationSchema.value,
  initialValues: initialValues.value,
  validateOnMount: false, // 初期表示時はバリデーションを実行しない
})

// マスターデータが取得できたらバリデーションスキーマを更新
watch(validationSchema, (newSchema) => {
  form.setValues(initialValues.value)
  // スキーマの更新は useForm の内部で行われるため、明示的な更新は不要
}, { immediate: true })

const { handleSubmit, meta: formMeta } = form

const { value: nameValue, errorMessage: nameError, meta: nameMeta } = useField<string>('name')
const { value: passwordValue, errorMessage: passwordError, meta: passwordMeta } =
  useField<string>('password')
const {
  value: passwordConfirmationValue,
  errorMessage: passwordConfirmationError,
  meta: passwordConfirmationMeta,
} = useField<string>('password_confirmation')
const { value: roleValue, errorMessage: roleError, meta: roleMeta } = useField<string>('role')

const isValid = computed(() => formMeta.value.valid)

const clearApiFieldError = (field: string) => {
  if (!apiFieldErrors.value[field]) return
  const next = { ...apiFieldErrors.value }
  delete next[field]
  apiFieldErrors.value = next
}

// エラー表示ロジック
const nameErrorToShow = useFieldError('name', apiFieldErrors, nameError, nameMeta)
const passwordErrorToShow = useFieldError('password', apiFieldErrors, passwordError, passwordMeta)
const passwordConfirmationErrorToShow = useFieldError(
  'password_confirmation',
  apiFieldErrors,
  passwordConfirmationError,
  passwordConfirmationMeta,
)
const roleErrorToShow = useFieldError('role', apiFieldErrors, roleError, roleMeta, {
  skipTouchedCheck: true,
})

const onSubmit = handleSubmit(async (values) => {
  apiError.value = null
  apiFieldErrors.value = {}

  if (!email.value || !token.value) {
    apiError.value =
      '招待情報が取得できませんでした。招待メールのリンクからアクセスし直してください。'
    return
  }

  loading.value = true

  try {
    const { data, error } = await apiFetchAction<{
      user: { id: number; name: string; email: string }
      family: { id: number; name: string }
    }>('/api/v1/invitations/complete', {
      method: 'POST',
      body: {
        token: token.value,
        name: values.name?.trim(),
        password: values.password,
        password_confirmation: values.password_confirmation,
        role: values.role || 'unspecified',
      },
    })

    if (error.value) {
      const errorData = error.value.data as any
      if (errorData?.errors) {
        apiFieldErrors.value = errorData.errors as ApiFieldErrors
      } else if (errorData?.error) {
        apiError.value = errorData.error
      } else {
        apiError.value = '登録に失敗しました'
      }
      return
    }

    if (data.value) {
      // 登録成功後、ユーザー情報と家族情報をストアに保存
      authStore.user = data.value.user
      authStore.family = data.value.family || null
      authStore.loggedIn = true

      // 招待関連の一時情報は不要なのでクリア
      if (process.client) {
        sessionStorage.removeItem('invitation_token')
        sessionStorage.removeItem('invitation_email')
        sessionStorage.removeItem('invitation_family_name')
        sessionStorage.removeItem('invitation_inviter_name')
      }

      router.push('/')
    }
  } catch (err: any) {
    apiError.value = err.message || '登録に失敗しました'
  } finally {
    loading.value = false
  }
})
</script>


