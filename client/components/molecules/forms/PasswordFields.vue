<template>
  <div class="space-y-6">
    <!-- パスワード -->
    <div>
      <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
        パスワード
      </label>
      <input
        id="password"
        :value="password"
        type="password"
        placeholder="6文字以上"
        class="w-full px-4 py-4 text-base rounded-lg border transition-all duration-200 outline-none touch-manipulation"
        :class="passwordError
          ? 'border-red-300 focus:ring-2 focus:ring-red-400 focus:border-transparent'
          : 'border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent'"
        :disabled="disabled"
        @input="handlePasswordInput"
        @blur="handlePasswordBlur"
      />
      <p v-if="passwordError" class="mt-2 text-sm text-red-600">
        {{ passwordError }}
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
        :value="passwordConfirmation"
        type="password"
        placeholder="もう一度入力"
        class="w-full px-4 py-4 text-base rounded-lg border transition-all duration-200 outline-none touch-manipulation"
        :class="passwordConfirmationError
          ? 'border-red-300 focus:ring-2 focus:ring-red-400 focus:border-transparent'
          : 'border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent'"
        :disabled="disabled"
        @input="handlePasswordConfirmationInput"
        @blur="handlePasswordConfirmationBlur"
      />
      <p v-if="passwordConfirmationError" class="mt-2 text-sm text-red-600">
        {{ passwordConfirmationError }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  password: string
  passwordError?: string | null
  passwordOnInputClearError?: () => void
  passwordOnBlurTouch?: () => void

  passwordConfirmation: string
  passwordConfirmationError?: string | null
  passwordConfirmationOnInputClearError?: () => void
  passwordConfirmationOnBlurTouch?: () => void

  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  password: '',
  passwordError: null,
  passwordOnInputClearError: undefined,
  passwordOnBlurTouch: undefined,
  passwordConfirmation: '',
  passwordConfirmationError: null,
  passwordConfirmationOnInputClearError: undefined,
  passwordConfirmationOnBlurTouch: undefined,
  disabled: false,
})

const emit = defineEmits<{
  (e: 'update:password', value: string): void
  (e: 'update:passwordConfirmation', value: string): void
}>()

const handlePasswordInput = (event: Event) => {
  const target = event.target as HTMLInputElement
  emit('update:password', target.value)
  props.passwordOnInputClearError?.()
}

const handlePasswordBlur = () => {
  props.passwordOnBlurTouch?.()
}

const handlePasswordConfirmationInput = (event: Event) => {
  const target = event.target as HTMLInputElement
  emit('update:passwordConfirmation', target.value)
  props.passwordConfirmationOnInputClearError?.()
}

const handlePasswordConfirmationBlur = () => {
  props.passwordConfirmationOnBlurTouch?.()
}
</script>

