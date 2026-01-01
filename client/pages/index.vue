<template>
  <div class="min-h-screen bg-gray-100 flex items-center justify-center">
    <div class="max-w-md w-full bg-white rounded-lg shadow-lg p-8">
      <h1 class="text-3xl font-bold text-gray-800 mb-6 text-center">
        FamilyOps
      </h1>
      
      <div class="space-y-4">
        <div class="p-4 bg-blue-50 rounded-lg">
          <p class="text-sm text-gray-600 mb-2">
            Tailwind CSSが正しく動作しています
          </p>
          <div class="flex items-center space-x-2">
            <div class="w-3 h-3 bg-green-500 rounded-full"></div>
            <span class="text-sm text-gray-700">スタイル適用済み</span>
          </div>
        </div>

        <button
          @click="testApiConnection"
          :disabled="loading"
          class="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-semibold py-3 px-4 rounded-lg transition-colors duration-200"
        >
          {{ loading ? '接続中...' : 'Rails APIとの疎通確認' }}
        </button>

        <div v-if="apiResponse" class="mt-4 p-4 bg-gray-50 rounded-lg">
          <p class="text-sm font-semibold text-gray-700 mb-2">APIレスポンス:</p>
          <pre class="text-xs text-gray-600 overflow-auto">{{ JSON.stringify(apiResponse, null, 2) }}</pre>
        </div>

        <div v-if="apiError" class="mt-4 p-4 bg-red-50 rounded-lg">
          <p class="text-sm font-semibold text-red-700 mb-2">エラー:</p>
          <p class="text-xs text-red-600">{{ apiError }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const loading = ref(false)
const apiResponse = ref<any>(null)
const apiError = ref<string | null>(null)

const testApiConnection = async () => {
  loading.value = true
  apiResponse.value = null
  apiError.value = null

  try {
    // Rails APIのヘルスチェックエンドポイントをテスト（プロキシ経由）
    const data = await $fetch('/api/up')
    apiResponse.value = data
  } catch (error: any) {
    apiError.value = error.message || '予期しないエラーが発生しました'
  } finally {
    loading.value = false
  }
}
</script>

