<template>
  <div>
    <label for="role" class="block text-sm font-medium text-gray-700 mb-2">
      家族内での役割（任意）
    </label>
    <select
      id="role"
      :value="modelValue"
      class="w-full px-4 py-4 text-base rounded-lg border border-gray-300 focus:ring-2 focus:ring-orange-400 focus:border-transparent transition-all duration-200 outline-none bg-white"
      :disabled="disabled || roleOptions.length === 0"
      @change="handleChange"
    >
      <option
        v-for="role in roleOptions"
        :key="role.value"
        :value="role.value"
      >
        {{ role.label }}
      </option>
    </select>
    <p
      v-if="roleOptions.length === 0"
      class="mt-2 text-sm text-gray-500"
    >
      役割の選択肢が取得できませんでした。ページを再読み込みしてください。
    </p>
    <p v-if="error" class="mt-2 text-sm text-red-600">
      {{ error }}
    </p>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useMasterDataStore } from '@/stores/masterData'
import type { RoleOption } from '@/stores/masterData'

interface Props {
  modelValue: string
  error?: string | null
  disabled?: boolean
  onChangeClearError?: () => void
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: 'unspecified',
  error: null,
  disabled: false,
  onChangeClearError: undefined,
})

const masterDataStore = useMasterDataStore()
const { roles } = storeToRefs(masterDataStore)

const roleOptions = computed<RoleOption[]>(() => {
  return roles.value
})

onMounted(async () => {
  if (!masterDataStore.loaded && !masterDataStore.loading) {
    await masterDataStore.fetchMasterData()
  }
})

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()

const handleChange = (event: Event) => {
  const target = event.target as HTMLSelectElement
  emit('update:modelValue', target.value)
  props.onChangeClearError?.()
}
</script>

