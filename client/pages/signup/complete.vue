<template>
  <div>
    <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 border border-orange-100">
      <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6 text-center">
        登録を完了する
      </h2>

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
          メールアドレスが取得できませんでした。メール送信画面からやり直してください。
        </p>
      </div>

      <form @submit="onSubmit" class="space-y-6">
        <!-- ユーザー名 -->
        <div>
          <label for="name" class="block text-sm font-medium text-gray-700 mb-2">
            ユーザー名
          </label>
          <input
            id="name"
            v-model="nameValue"
            type="text"
            placeholder="例）はなこ"
            class="w-full px-4 py-4 text-base rounded-lg border transition-all duration-200 outline-none touch-manipulation"
            :class="nameErrorToShow ? 'border-red-300 focus:ring-2 focus:ring-red-400 focus:border-transparent' : 'border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent'"
            :disabled="loading || !email"
            @input="clearApiFieldError('name')"
            @blur="nameMeta.touched = true"
          />
          <p v-if="nameErrorToShow" class="mt-2 text-sm text-red-600">
            {{ nameErrorToShow }}
          </p>
        </div>

        <!-- パスワード -->
        <div>
          <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
            パスワード
          </label>
          <input
            id="password"
            v-model="passwordValue"
            type="password"
            placeholder="6文字以上"
            class="w-full px-4 py-4 text-base rounded-lg border transition-all duration-200 outline-none touch-manipulation"
            :class="passwordErrorToShow ? 'border-red-300 focus:ring-2 focus:ring-red-400 focus:border-transparent' : 'border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent'"
            :disabled="loading || !email"
            @input="clearApiFieldError('password')"
            @blur="passwordMeta.touched = true"
          />
          <p v-if="passwordErrorToShow" class="mt-2 text-sm text-red-600">
            {{ passwordErrorToShow }}
          </p>
        </div>

        <!-- パスワード（確認用） -->
        <div>
          <label
            for="password_confirmation"
            class="block text-sm font-medium text-gray-700 mb-2"
          >
            パスワード（確認用）
          </label>
          <input
            id="password_confirmation"
            v-model="passwordConfirmationValue"
            type="password"
            placeholder="もう一度入力"
            class="w-full px-4 py-4 text-base rounded-lg border transition-all duration-200 outline-none touch-manipulation"
            :class="passwordConfirmationErrorToShow ? 'border-red-300 focus:ring-2 focus:ring-red-400 focus:border-transparent' : 'border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent'"
            :disabled="loading || !email"
            @input="clearApiFieldError('password_confirmation')"
            @blur="passwordConfirmationMeta.touched = true"
          />
          <p v-if="passwordConfirmationErrorToShow" class="mt-2 text-sm text-red-600">
            {{ passwordConfirmationErrorToShow }}
          </p>
        </div>

        <!-- 家族名 -->
        <div>
          <label for="family_name" class="block text-sm font-medium text-gray-700 mb-2">
            家族名
          </label>
          <input
            id="family_name"
            v-model="familyNameValue"
            type="text"
            placeholder="例）田中家"
            class="w-full px-4 py-4 text-base rounded-lg border transition-all duration-200 outline-none touch-manipulation"
            :class="familyNameErrorToShow ? 'border-red-300 focus:ring-2 focus:ring-red-400 focus:border-transparent' : 'border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent'"
            :disabled="loading || !email"
            @input="clearApiFieldError('family_name')"
            @blur="familyNameMeta.touched = true"
          />
          <p v-if="familyNameErrorToShow" class="mt-2 text-sm text-red-600">
            {{ familyNameErrorToShow }}
          </p>
        </div>

        <!-- 役割 -->
        <div>
          <label for="role" class="block text-sm font-medium text-gray-700 mb-2">
            家族内での役割（任意）
          </label>
          <select
            id="role"
            v-model="roleValue"
            class="w-full px-4 py-4 text-base rounded-lg border border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all duration-200 outline-none bg-white"
            :disabled="loading || !email"
            @change="clearApiFieldError('role')"
          >
            <option value="unspecified">指定なし</option>
            <option value="mother">母</option>
            <option value="father">父</option>
            <option value="child">子</option>
            <option value="other">その他</option>
          </select>
          <p v-if="roleErrorToShow" class="mt-2 text-sm text-red-600">
            {{ roleErrorToShow }}
          </p>
        </div>

        <!-- エラーメッセージ（API側の汎用エラー） -->
        <div
          v-if="apiError"
          class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm"
        >
          {{ apiError }}
        </div>

        <!-- 登録ボタン -->
        <button
          type="submit"
          :disabled="loading || !email || !isValid"
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
          <span v-else>登録を完了</span>
        </button>
      </form>

      <div class="mt-6 text-center">
        <NuxtLink to="/signup/email" class="text-sm text-orange-600 hover:underline">
          メール送信画面に戻る
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useForm, useField } from 'vee-validate'
import * as yup from 'yup'

definePageMeta({
  layout: 'auth',
})

type ApiFieldErrors = Record<string, string[]>

const router = useRouter()
const { apiFetchAction } = useApi()

const email = ref<string>('')
const loading = ref(false)
const apiError = ref<string | null>(null)
const apiFieldErrors = ref<ApiFieldErrors>({})

onMounted(() => {
  // verify画面で保存される想定（現状は email送信時にも保存している）
  const stored = sessionStorage.getItem('signup_email')
  email.value = stored || ''
})

const validationSchema = yup.object({
  name: yup.string().required('ユーザー名を入力してください'),
  password: yup
    .string()
    .required('パスワードを入力してください')
    .min(6, 'パスワードは6文字以上で入力してください'),
  password_confirmation: yup
    .string()
    .required('パスワード（確認用）を入力してください')
    .oneOf([yup.ref('password')], 'パスワード（確認用）とパスワードが一致しません'),
  family_name: yup.string().required('家族名を入力してください'),
  role: yup.string().oneOf(['unspecified', 'mother', 'father', 'child', 'other']).default('unspecified'),
})

const { handleSubmit, meta: formMeta } = useForm({
  validationSchema,
  initialValues: {
    role: 'unspecified',
  },
})

const { value: nameValue, errorMessage: nameError, meta: nameMeta } = useField<string>('name')
const { value: passwordValue, errorMessage: passwordError, meta: passwordMeta } =
  useField<string>('password')
const {
  value: passwordConfirmationValue,
  errorMessage: passwordConfirmationError,
  meta: passwordConfirmationMeta,
} = useField<string>('password_confirmation')
const {
  value: familyNameValue,
  errorMessage: familyNameError,
  meta: familyNameMeta,
} = useField<string>('family_name')
const { value: roleValue, errorMessage: roleError } = useField<string>('role')

const isValid = computed(() => formMeta.value.valid)

const clearApiFieldError = (field: string) => {
  if (!apiFieldErrors.value[field]) return
  const next = { ...apiFieldErrors.value }
  delete next[field]
  apiFieldErrors.value = next
}

// APIエラーを最優先で表示（画面側のバリデーションはその次）
const nameErrorToShow = computed(() => apiFieldErrors.value.name?.[0] || nameError.value || null)
const passwordErrorToShow = computed(
  () => apiFieldErrors.value.password?.[0] || passwordError.value || null,
)
const passwordConfirmationErrorToShow = computed(
  () =>
    apiFieldErrors.value.password_confirmation?.[0] || passwordConfirmationError.value || null,
)
const familyNameErrorToShow = computed(
  () => apiFieldErrors.value.family_name?.[0] || familyNameError.value || null,
)
const roleErrorToShow = computed(() => apiFieldErrors.value.role?.[0] || roleError.value || null)

const onSubmit = handleSubmit(async (values) => {
  apiError.value = null
  apiFieldErrors.value = {}

  if (!email.value) {
    apiError.value = 'メールアドレスが取得できませんでした。メール送信画面からやり直してください。'
    return
  }

  loading.value = true

  try {
    const { data, error } = await apiFetchAction<{
      user: { id: number; name: string; email: string }
      family: { id: number; name: string }
    }>('/api/v1/signup/complete', {
      method: 'POST',
      body: {
        email: email.value,
        name: values.name?.trim(),
        password: values.password,
        password_confirmation: values.password_confirmation,
        family_name: values.family_name?.trim(),
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
      // 登録完了後は不要なのでクリア（再送の導線では必要になるので、残す方針なら消さない）
      sessionStorage.removeItem('signup_email')
      router.push('/')
    }
  } catch (err: any) {
    apiError.value = err.message || '登録に失敗しました'
  } finally {
    loading.value = false
  }
})
</script>


