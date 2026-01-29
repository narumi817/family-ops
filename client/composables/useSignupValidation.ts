import * as yup from 'yup'
import { useMasterDataStore } from '@/stores/masterData'
import { storeToRefs } from 'pinia'
import type { FieldMeta } from 'vee-validate'

export interface UseSignupValidationOptions {
  includeFamilyName?: boolean
}

type ApiFieldErrors = Record<string, string[]>

/**
 * フィールドのエラー表示ロジックを提供する composable
 * APIエラーを最優先で表示し、バリデーションエラーは touched が true のときのみ表示
 */
export function useFieldError(
  fieldName: string,
  apiFieldErrors: Ref<ApiFieldErrors>,
  validationError: Ref<string | undefined>,
  meta: FieldMeta<string>,
  options?: { skipTouchedCheck?: boolean }
) {
  return computed(() => {
    // APIエラーを最優先
    if (apiFieldErrors.value[fieldName]?.[0]) {
      return apiFieldErrors.value[fieldName][0]
    }
    // バリデーションエラーは touched が true のときのみ表示（skipTouchedCheck が true の場合は常に表示）
    if (options?.skipTouchedCheck || meta.touched) {
      if (validationError.value) {
        return validationError.value
      }
    }
    return null
  })
}

/**
 * サインアップ・招待完了画面で共通のバリデーションスキーマを生成する composable
 */
export function useSignupValidationSchema(options: UseSignupValidationOptions = {}) {
  const { includeFamilyName = false } = options

  const masterDataStore = useMasterDataStore()
  const { roles } = storeToRefs(masterDataStore)

  // マスターAPIから取得した役割のvalueの配列を取得
  const roleValues = computed(() => {
    if (roles.value.length > 0) {
      return roles.value.map((r) => r.value)
    }
    // API未取得時は空配列を返す（バリデーションは通らないが、UI側でメッセージを表示）
    return []
  })

  // バリデーションスキーマを生成
  const validationSchema = computed(() => {
    const baseSchema: Record<string, any> = {
      name: yup.string().required('ユーザー名を入力してください'),
      password: yup
        .string()
        .required('パスワードを入力してください')
        .min(6, 'パスワードは6文字以上で入力してください'),
      password_confirmation: yup
        .string()
        .required('パスワード（確認用）を入力してください')
        .oneOf([yup.ref('password')], 'パスワード（確認用）とパスワードが一致しません'),
    }

    // 役割のバリデーション（マスターAPIから取得した値を使用）
    if (roleValues.value.length > 0) {
      baseSchema.role = yup
        .string()
        .oneOf(roleValues.value, '有効な役割を選択してください')
        .default('unspecified')
    } else {
      // API未取得時は任意（バリデーションエラーにはならないが、UI側で選択肢が表示されない）
      baseSchema.role = yup.string().optional()
    }

    // 家族名のスキーマ（signup/complete.vue のみ）
    if (includeFamilyName) {
      baseSchema.family_name = yup.string().required('家族名を入力してください')
    }

    return yup.object(baseSchema)
  })

  // useForm の初期値
  const initialValues = computed(() => {
    const base: Record<string, any> = {
      role: 'unspecified',
    }
    if (includeFamilyName) {
      base.family_name = ''
    }
    return base
  })

  return {
    validationSchema,
    initialValues,
    roleValues,
  }
}

