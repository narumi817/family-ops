<template>
  <div>
    <label for="name" class="block text-sm font-medium text-gray-700 mb-2">
      ユーザー名
    </label>
    <input
      id="name"
      :value="modelValue"
      type="text"
      placeholder="例）はなこ"
      class="w-full px-4 py-4 text-base rounded-lg border transition-all duration-200 outline-none touch-manipulation"
      :class="error
        ? 'border-red-300 focus:ring-2 focus:ring-red-400 focus:border-transparent'
        : 'border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent'"
      :disabled="disabled"
      @input="handleInput"
      @blur="handleBlur"
    />
    <p v-if="error" class="mt-2 text-sm text-red-600">
      {{ error }}
    </p>
  </div>
</template>

<script setup lang="ts">
interface Props {
  modelValue: string
  error?: string | null
  disabled?: boolean
  onInputClearError?: () => void
  onBlurTouch?: () => void
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: '',
  error: null,
  disabled: false,
  onInputClearError: undefined,
  onBlurTouch: undefined,
})

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()

const handleInput = (event: Event) => {
  const target = event.target as HTMLInputElement
  emit('update:modelValue', target.value)
  props.onInputClearError?.()
}

const handleBlur = () => {
  props.onBlurTouch?.()
}
</script>

