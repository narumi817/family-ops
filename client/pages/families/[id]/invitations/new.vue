<template>
  <div>
    <!-- ページタイトル -->
    <div class="mb-6">
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-800 mb-2">家族メンバーを招待</h1>
      <p class="text-sm sm:text-base text-gray-600">招待したい家族メンバーのメールアドレスを入力してください</p>
    </div>

    <!-- フォーム -->
    <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 border border-orange-100">
      <form @submit="onSubmit" class="space-y-6">
        <!-- メールアドレス -->
        <div>
          <label
            for="email"
            class="block text-sm font-medium text-gray-700 mb-2"
          >
            招待先メールアドレス
          </label>
          <input
            id="email"
            v-model="emailValue"
            type="email"
            placeholder="example@email.com"
            class="w-full px-4 py-4 text-base rounded-lg border transition-all duration-200 outline-none touch-manipulation"
            :class="emailError ? 'border-red-300 focus:ring-2 focus:ring-red-400 focus:border-transparent' : 'border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent'"
            :disabled="loading"
            @blur="emailMeta.touched = true"
          />
          <!-- エラーメッセージ -->
          <p v-if="emailError" class="mt-2 text-sm text-red-600">
            {{ emailError }}
          </p>
        </div>

        <!-- 成功メッセージ -->
        <div
          v-if="successMessage"
          class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg text-sm"
        >
          {{ successMessage }}
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
          :disabled="loading || !isValid"
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
          <span v-else>招待メールを送信</span>
        </button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useForm } from 'vee-validate'
import * as yup from 'yup'

definePageMeta({
  layout: 'default',
})

const route = useRoute()
const router = useRouter()
const { apiFetchAction } = useApi()

const familyId = computed(() => route.params.id as string)

// バリデーションスキーマ
const validationSchema = yup.object({
  email: yup
    .string()
    .required('メールアドレスを入力してください')
    .email('有効なメールアドレスを入力してください'),
})

const { handleSubmit, values, errors: validationErrors, meta: emailMeta } = useForm({
  validationSchema,
  initialValues: {
    email: '',
  },
})

const emailValue = computed({
  get: () => values.email,
  set: (value: string) => {
    values.email = value
  },
})

const emailError = computed(() => {
  if (emailMeta.value.touched && validationErrors.value.email) {
    return validationErrors.value.email
  }
  return null
})

const isValid = computed(() => {
  return !validationErrors.value.email && values.email.trim() !== ''
})

const loading = ref(false)
const apiError = ref<string | null>(null)
const successMessage = ref<string | null>(null)

const onSubmit = handleSubmit(async (formValues) => {
  apiError.value = null
  successMessage.value = null
  loading.value = true

  try {
    const { data, error } = await apiFetchAction<{
      message: string
      invitation: {
        id: number
        email: string
        family_id: number
      }
    }>(`/api/v1/families/${familyId.value}/invitations`, {
      method: 'POST',
      body: {
        email: formValues.email.trim(),
      },
    })

    if (error.value) {
      const errorData = error.value.data as any
      if (errorData?.errors?.email) {
        apiError.value = errorData.errors.email[0] || 'メールアドレスの形式が正しくありません'
      } else if (errorData?.error) {
        apiError.value = errorData.error
      } else {
        apiError.value = '招待メールの送信に失敗しました'
      }
      return
    }

    if (data.value) {
      successMessage.value = data.value.message || '招待メールを送信しました'
      // フォームをリセット
      values.email = ''
      emailMeta.value.touched = false
    }
  } catch (err: any) {
    apiError.value = err.message || '招待メールの送信に失敗しました'
  } finally {
    loading.value = false
  }
})
</script>

