<template>
  <div>
    <!-- ヘッダー -->
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-800">タスク管理</h1>
    </div>

    <!-- ローディング -->
    <div v-if="loading" class="bg-white rounded-2xl shadow-xl p-6 sm:p-8">
      <div class="text-center py-8">
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
        <p class="text-sm text-gray-600">読み込み中...</p>
      </div>
    </div>

    <!-- エラー -->
    <div v-else-if="error" class="bg-white rounded-2xl shadow-xl p-6 sm:p-8">
      <div class="text-center py-8">
        <p class="text-red-500 mb-4">{{ error }}</p>
        <button
          @click="fetchTasks"
          class="px-4 py-2 bg-orange-400 text-white rounded-lg hover:bg-orange-500 transition-colors"
        >
          再読み込み
        </button>
      </div>
    </div>

    <!-- タスク一覧 -->
    <div v-else class="bg-white rounded-2xl shadow-xl p-6 sm:p-8">
      <div v-if="tasks.length === 0" class="text-center py-8">
        <p class="text-gray-500">タスクがありません</p>
      </div>

      <div v-else class="space-y-4">
        <div
          v-for="task in tasks"
          :key="task.id"
          class="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
        >
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <div class="flex items-center mb-2">
                <span
                  class="inline-block px-2 py-1 text-xs font-medium rounded mr-2"
                  :class="categoryBadgeClass(task.category)"
                >
                  {{ categoryLabel(task.category) }}
                </span>
                <span v-if="task.is_custom" class="text-xs text-gray-500">（カスタム）</span>
              </div>
              <h3 class="text-lg font-semibold text-gray-900 mb-1">{{ task.name }}</h3>
              <p v-if="task.description" class="text-sm text-gray-600 mb-2">
                {{ task.description }}
              </p>
              <div class="flex items-center">
                <span class="text-sm text-gray-500 mr-2">ポイント:</span>
                <span class="text-lg font-bold text-orange-500">{{ task.family_points }}</span>
                <span class="text-sm text-gray-400 ml-1">pt</span>
                <span v-if="task.family_points !== task.points" class="text-xs text-gray-400 ml-2">
                  （デフォルト: {{ task.points }}pt）
                </span>
              </div>
            </div>
            <button
              @click="openEditModal(task)"
              class="ml-4 px-4 py-2 bg-orange-400 text-white rounded-lg hover:bg-orange-500 transition-colors text-sm font-medium"
            >
              ポイント編集
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- ポイント編集モーダル -->
    <Teleport to="body">
      <div
        v-if="editingTask"
        class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
        @click.self="closeEditModal"
      >
      <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 max-w-md w-full">
        <h2 class="text-xl font-semibold text-gray-800 mb-4">ポイントを編集</h2>
        <p class="text-sm text-gray-600 mb-2">{{ editingTask.name }}</p>
        <p class="text-xs text-gray-400 mb-6">デフォルトポイント: {{ editingTask.points }}pt</p>

        <form @submit.prevent="handleUpdatePoints" class="space-y-4">
          <div>
            <label for="points" class="block text-sm font-medium text-gray-700 mb-2">
              ポイント <span class="text-red-500">*</span>
            </label>
            <input
              id="points"
              v-model.number="editPoints"
              type="number"
              min="0"
              step="1"
              class="w-full min-h-[48px] px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-gray-900 bg-white"
              :class="{ 'border-red-500': editError }"
              required
            />
            <p v-if="editError" class="mt-1 text-sm text-red-500">{{ editError }}</p>
          </div>

          <div class="flex space-x-3 pt-4">
            <button
              type="button"
              @click="closeEditModal"
              class="flex-1 px-4 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors font-medium"
            >
              キャンセル
            </button>
            <button
              type="submit"
              :disabled="updating"
              class="flex-1 px-4 py-3 bg-gradient-to-r from-orange-400 to-pink-400 text-white rounded-lg shadow-md active:shadow-sm active:scale-[0.98] transition-all duration-200 font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="updating">更新中...</span>
              <span v-else>更新する</span>
            </button>
          </div>
        </form>
      </div>
    </div>
    </Teleport>
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

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const { apiFetchAction } = useApi()

definePageMeta({
  layout: 'default',
})

const familyId = computed(() => parseInt(route.params.id as string))
const loading = ref(false)
const error = ref<string | null>(null)
const tasks = ref<Task[]>([])
const editingTask = ref<Task | null>(null)
const editPoints = ref<number>(0)
const editError = ref<string | null>(null)
const updating = ref(false)

// カテゴリのラベル
const categoryLabel = (category: string): string => {
  const labels: Record<string, string> = {
    childcare: '育児',
    housework: '家事',
    other: 'その他',
  }
  return labels[category] || category
}

// カテゴリのバッジクラス
const categoryBadgeClass = (category: string): string => {
  const classes: Record<string, string> = {
    childcare: 'bg-blue-100 text-blue-800',
    housework: 'bg-green-100 text-green-800',
    other: 'bg-gray-100 text-gray-800',
  }
  return classes[category] || 'bg-gray-100 text-gray-800'
}

// タスク一覧を取得
const fetchTasks = async () => {
  if (!authStore.loggedIn || !authStore.family) return

  loading.value = true
  error.value = null

  try {
    const { data, error: fetchError } = await apiFetchAction<TasksResponse>(
      `/api/v1/families/${familyId.value}/tasks`,
      {
        method: 'GET',
      }
    )

    if (fetchError.value) {
      error.value = 'タスクの取得に失敗しました'
      console.error('Failed to fetch tasks:', fetchError.value)
      return
    }

    if (data.value) {
      tasks.value = data.value.tasks
    }
  } catch (e) {
    error.value = 'タスクの取得に失敗しました'
    console.error('Failed to fetch tasks:', e)
  } finally {
    loading.value = false
  }
}

// 編集モーダルを開く
const openEditModal = (task: Task) => {
  console.log('openEditModal called with task:', task)
  editingTask.value = task
  editPoints.value = task.family_points
  editError.value = null
  console.log('editingTask.value:', editingTask.value)
}

// 編集モーダルを閉じる
const closeEditModal = () => {
  editingTask.value = null
  editPoints.value = 0
  editError.value = null
}

// ポイントを更新
const handleUpdatePoints = async () => {
  if (!editingTask.value) return

  editError.value = null
  updating.value = true

  try {
    const { data, error: updateError } = await apiFetchAction(
      `/api/v1/families/${familyId.value}/tasks/${editingTask.value.id}/points`,
      {
        method: 'PUT',
        body: {
          points: editPoints.value,
        },
      }
    )

    if (updateError.value) {
      const errorData = updateError.value.data
      if (errorData?.error) {
        editError.value = errorData.error
      } else if (errorData?.errors && Array.isArray(errorData.errors)) {
        editError.value = errorData.errors.join(', ')
      } else {
        editError.value = 'ポイントの更新に失敗しました'
      }
      console.error('Failed to update points:', updateError.value)
      return
    }

    // 成功時はモーダルを閉じてタスク一覧を再取得
    closeEditModal()
    await fetchTasks()
  } catch (e) {
    editError.value = 'ポイントの更新に失敗しました'
    console.error('Failed to update points:', e)
  } finally {
    updating.value = false
  }
}

// ページ読み込み時にタスク一覧を取得
onMounted(async () => {
  await authStore.checkLoginStatus()
  if (!authStore.loggedIn) {
    router.push('/login')
    return
  }

  // 家族IDの検証
  if (!authStore.family || authStore.family.id !== familyId.value) {
    router.push('/')
    return
  }

  await fetchTasks()
})
</script>

