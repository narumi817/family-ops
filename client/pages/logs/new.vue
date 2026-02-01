<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-pink-50 to-yellow-50">
    <div class="container mx-auto px-4 py-8">
      <!-- ヘッダー -->
      <header class="flex items-center mb-6 sm:mb-8">
        <button
          @click="router.back()"
          class="mr-4 p-2 text-gray-700 hover:bg-white rounded-lg transition-colors"
        >
          <svg
            class="w-6 h-6"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M15 19l-7-7 7-7"
            />
          </svg>
        </button>
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-800">ログを追加</h1>
      </header>

      <!-- フォーム -->
      <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8">
        <!-- ローディング -->
        <div v-if="loadingTasks" class="text-center py-8">
          <div class="inline-flex items-center justify-center w-12 h-12 bg-orange-50 rounded-full mb-4">
            <svg
              class="animate-spin h-6 w-6 text-orange-500"
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
          <p class="text-sm text-gray-600">タスクを読み込み中...</p>
        </div>

        <!-- エラー -->
        <div v-else-if="tasksError" class="text-center py-8">
          <p class="text-red-500 mb-4">タスクの取得に失敗しました</p>
          <button
            @click="fetchTasks"
            class="px-4 py-2 bg-orange-400 text-white rounded-lg hover:bg-orange-500 transition-colors"
          >
            再読み込み
          </button>
        </div>

        <!-- フォーム -->
        <form v-else @submit.prevent="handleSubmit" class="space-y-6">
          <!-- タスク選択 -->
          <div>
            <label for="task" class="block text-sm font-medium text-gray-700 mb-2">
              タスク <span class="text-red-500">*</span>
            </label>
            <select
              id="task"
              v-model="formData.task_id"
              class="w-full min-h-[48px] px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-gray-900 bg-white"
              :class="{ 'border-red-500': errors.task_id }"
            >
              <option value="">選択してください</option>
              <optgroup
                v-for="(tasks, category) in tasksByCategory"
                :key="category"
                :label="categoryLabel(category)"
              >
                <option
                  v-for="task in tasks"
                  :key="task.id"
                  :value="task.id"
                >
                  {{ task.name }} ({{ task.family_points }}pt)
                </option>
              </optgroup>
            </select>
            <p v-if="errors.task_id" class="mt-1 text-sm text-red-500">
              {{ errors.task_id }}
            </p>
          </div>

          <!-- 実行日時 -->
          <div>
            <label for="performed_at" class="block text-sm font-medium text-gray-700 mb-2">
              実行日時
            </label>
            <input
              id="performed_at"
              v-model="formData.performed_at"
              type="datetime-local"
              class="w-full min-h-[48px] px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-gray-900 bg-white"
              :class="{ 'border-red-500': errors.performed_at }"
            />
            <p v-if="errors.performed_at" class="mt-1 text-sm text-red-500">
              {{ errors.performed_at }}
            </p>
            <p class="mt-1 text-xs text-gray-500">
              未指定の場合は現在時刻になります
            </p>
          </div>

          <!-- メモ -->
          <div>
            <label for="notes" class="block text-sm font-medium text-gray-700 mb-2">
              メモ
            </label>
            <textarea
              id="notes"
              v-model="formData.notes"
              rows="4"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-gray-900 bg-white resize-none"
              placeholder="メモを入力（任意）"
            />
          </div>

          <!-- APIエラー -->
          <div v-if="apiError" class="bg-red-50 border border-red-200 rounded-lg p-4">
            <p class="text-sm text-red-600">{{ apiError }}</p>
          </div>

          <!-- 送信ボタン -->
          <div class="pt-4">
            <button
              type="submit"
              :disabled="submitting"
              class="w-full min-h-[56px] bg-gradient-to-r from-orange-400 to-pink-400 text-white rounded-lg shadow-md active:shadow-sm active:scale-[0.98] transition-all duration-200 text-base font-semibold touch-manipulation disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="submitting">登録中...</span>
              <span v-else>登録する</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Task {
  id: number
  name: string
  description: string | null
  category: string
  points: number
  family_points: number
  is_custom: boolean
}

interface TasksResponse {
  tasks: Task[]
}

const router = useRouter()
const authStore = useAuthStore()
const { apiFetchAction } = useApi()

definePageMeta({
  layout: 'default',
})

const loadingTasks = ref(false)
const tasks = ref<Task[]>([])
const tasksError = ref<string | null>(null)
const submitting = ref(false)
const apiError = ref<string | null>(null)

const formData = ref({
  task_id: '',
  performed_at: '',
  notes: '',
})

const errors = ref<Record<string, string>>({})

// 現在日時をデフォルト値として設定（YYYY-MM-DDTHH:mm形式）
const setDefaultDateTime = () => {
  const now = new Date()
  const year = now.getFullYear()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  const day = String(now.getDate()).padStart(2, '0')
  const hours = String(now.getHours()).padStart(2, '0')
  const minutes = String(now.getMinutes()).padStart(2, '0')
  formData.value.performed_at = `${year}-${month}-${day}T${hours}:${minutes}`
}

// タスクをカテゴリごとにグループ化
const tasksByCategory = computed(() => {
  const grouped: Record<string, Task[]> = {}
  tasks.value.forEach((task) => {
    if (!grouped[task.category]) {
      grouped[task.category] = []
    }
    grouped[task.category].push(task)
  })
  return grouped
})

// カテゴリのラベル
const categoryLabel = (category: string): string => {
  const labels: Record<string, string> = {
    childcare: '育児',
    housework: '家事',
    other: 'その他',
  }
  return labels[category] || category
}

// タスク一覧を取得
const fetchTasks = async () => {
  if (!authStore.loggedIn || !authStore.family) return

  loadingTasks.value = true
  tasksError.value = null

  try {
    const { data, error } = await apiFetchAction<TasksResponse>(
      `/api/v1/families/${authStore.family.id}/tasks`,
      {
        method: 'GET',
      }
    )

    if (error.value) {
      tasksError.value = 'タスクの取得に失敗しました'
      console.error('Failed to fetch tasks:', error.value)
      return
    }

    if (data.value) {
      tasks.value = data.value.tasks
    }
  } catch (e) {
    tasksError.value = 'タスクの取得に失敗しました'
    console.error('Failed to fetch tasks:', e)
  } finally {
    loadingTasks.value = false
  }
}

// バリデーション
const validate = (): boolean => {
  errors.value = {}

  if (!formData.value.task_id) {
    errors.value.task_id = 'タスクを選択してください'
  }

  if (formData.value.performed_at) {
    const date = new Date(formData.value.performed_at)
    if (isNaN(date.getTime())) {
      errors.value.performed_at = '有効な日時を入力してください'
    }
  }

  return Object.keys(errors.value).length === 0
}

// フォーム送信
const handleSubmit = async () => {
  if (!validate()) return

  submitting.value = true
  apiError.value = null

  try {
    const payload: any = {
      task_id: parseInt(formData.value.task_id),
    }

    if (formData.value.performed_at) {
      // datetime-local形式をISO 8601形式に変換
      const date = new Date(formData.value.performed_at)
      payload.performed_at = date.toISOString()
    }

    if (formData.value.notes) {
      payload.notes = formData.value.notes
    }

    const { data, error } = await apiFetchAction('/api/v1/logs', {
      method: 'POST',
      body: {
        log: payload,
      },
    })

    if (error.value) {
      const errorData = error.value.data
      if (errorData?.errors && Array.isArray(errorData.errors)) {
        apiError.value = errorData.errors.join(', ')
      } else {
        apiError.value = 'ログの登録に失敗しました'
      }
      console.error('Failed to create log:', error.value)
      return
    }

    // 成功時はログ一覧画面に戻る
    router.push('/')
  } catch (e) {
    apiError.value = 'ログの登録に失敗しました'
    console.error('Failed to create log:', e)
  } finally {
    submitting.value = false
  }
}

// ページ読み込み時にタスク一覧を取得
onMounted(async () => {
  await authStore.checkLoginStatus()
  if (!authStore.loggedIn) {
    router.push('/login')
    return
  }

  setDefaultDateTime()
  await fetchTasks()
})
</script>

