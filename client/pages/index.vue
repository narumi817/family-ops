<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-pink-50 to-yellow-50">
    <div class="container mx-auto px-4 py-8">
      <!-- ローディング中 -->
      <div v-if="checkingAuth" class="flex items-center justify-center min-h-[400px]">
        <div class="text-center">
          <div class="inline-flex items-center justify-center w-16 h-16 bg-orange-50 rounded-full mb-4">
            <svg
              class="animate-spin h-8 w-8 text-orange-500"
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

      <!-- 認証状態確認完了後 -->
      <template v-else>
        <!-- ヘッダー -->
        <header class="flex justify-between items-center mb-6 sm:mb-8">
          <h1 class="text-2xl sm:text-3xl font-bold text-gray-800">FamilyOps</h1>
          <NuxtLink
            v-if="!authStore.loggedIn"
            to="/login"
            class="min-h-[48px] px-4 sm:px-6 py-3 bg-gradient-to-r from-orange-400 to-pink-400 text-white rounded-lg shadow-md active:shadow-sm active:scale-[0.98] transition-all duration-200 text-sm sm:text-base font-medium touch-manipulation inline-flex items-center justify-center"
          >
            ログイン
          </NuxtLink>
        </header>

        <!-- ログイン済み: ログ一覧画面 -->
        <div v-if="authStore.loggedIn">
          <!-- 当日の累計ポイント -->
          <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 mb-6">
            <div class="text-center">
              <p class="text-sm text-gray-600 mb-2">今日のあなたのポイント</p>
              <p class="text-4xl sm:text-5xl font-bold text-orange-500 mb-1">
                {{ todayPoints }}
              </p>
              <p class="text-xs text-gray-500">pt</p>
            </div>
          </div>

          <!-- ログを追加ボタン -->
          <div class="mb-6">
            <NuxtLink
              to="/logs/new"
              class="flex items-center justify-center min-h-[56px] w-full bg-gradient-to-r from-orange-400 to-pink-400 text-white rounded-lg shadow-md active:shadow-sm active:scale-[0.98] transition-all duration-200 text-base font-semibold touch-manipulation"
            >
              <svg
                class="w-5 h-5 mr-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 4v16m8-8H4"
                />
              </svg>
              ログを追加
            </NuxtLink>
          </div>

          <!-- ログ一覧 -->
          <div class="bg-white rounded-2xl shadow-xl p-6 sm:p-8">
            <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6">今日のログ</h2>

            <!-- ローディング -->
            <div v-if="loadingLogs" class="text-center py-8">
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

            <!-- エラー -->
            <div v-else-if="logsError" class="text-center py-8">
              <p class="text-red-500 mb-4">ログの取得に失敗しました</p>
              <button
                @click="fetchLogs"
                class="px-4 py-2 bg-orange-400 text-white rounded-lg hover:bg-orange-500 transition-colors"
              >
                再読み込み
              </button>
            </div>

            <!-- ログなし -->
            <div v-else-if="logs.length === 0" class="text-center py-8">
              <p class="text-gray-500 mb-4">まだログがありません</p>
              <p class="text-sm text-gray-400">「ログを追加」ボタンからタスクを登録しましょう</p>
            </div>

            <!-- ログ一覧 -->
            <div v-else class="space-y-4">
              <div
                v-for="log in logs"
                :key="log.id"
                class="border-l-4 pl-4 py-3"
                :style="{ borderColor: getUserColor(log.user.id) }"
              >
                <div class="flex items-start justify-between mb-2">
                  <div class="flex-1">
                    <div class="flex items-center mb-1">
                      <span
                        class="inline-block w-3 h-3 rounded-full mr-2"
                        :style="{ backgroundColor: getUserColor(log.user.id) }"
                      />
                      <span class="font-semibold text-gray-800">{{ log.user.name }}</span>
                    </div>
                    <p class="text-lg font-medium text-gray-900 mb-1">{{ log.task.name }}</p>
                    <p class="text-sm text-gray-500">
                      {{ formatDateTime(log.performed_at) }}
                    </p>
                  </div>
                  <div class="text-right">
                    <p class="text-lg font-bold text-orange-500">+{{ log.task.points }}</p>
                    <p class="text-xs text-gray-400">pt</p>
                  </div>
                </div>
                <p v-if="log.notes" class="text-sm text-gray-600 mt-2 pl-5">
                  {{ log.notes }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- 未ログイン -->
        <div v-else class="bg-white rounded-2xl shadow-xl p-6 sm:p-8 text-center">
          <p class="text-sm sm:text-base text-gray-600 mb-6">ログインして、家族の毎日を記録しましょう</p>
          <NuxtLink
            to="/login"
            class="inline-flex items-center justify-center min-h-[56px] px-6 py-4 bg-gradient-to-r from-orange-400 to-pink-400 text-white rounded-lg shadow-md active:shadow-sm active:scale-[0.98] transition-all duration-200 text-base font-semibold touch-manipulation"
          >
            ログイン画面へ
          </NuxtLink>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
interface LogTask {
  id: number
  name: string
  category: string
  points: number
}

interface LogUser {
  id: number
  name: string
}

interface Log {
  id: number
  task: LogTask
  user: LogUser
  performed_at: string
  notes: string | null
  created_at: string
}

interface LogsResponse {
  logs: Log[]
  current_page: number
  total_pages: number
  total_count: number
}

interface TodayPointsResponse {
  user_id: number
  user_name: string
  today_points: number
  date: string
}

const authStore = useAuthStore()
const router = useRouter()
const { apiFetch, apiFetchAction } = useApi()

const checkingAuth = ref(true)
const loadingLogs = ref(false)
const logs = ref<Log[]>([])
const logsError = ref<string | null>(null)
const todayPoints = ref<number>(0)

// ユーザーIDに基づいて色を割り当てる（4人まで対応）
const getUserColor = (userId: number): string => {
  const colors = [
    '#F97316', // orange-500
    '#EC4899', // pink-500
    '#8B5CF6', // purple-500
    '#10B981', // emerald-500
  ]
  return colors[userId % colors.length]
}

// 日時をフォーマット
const formatDateTime = (dateTimeString: string): string => {
  const date = new Date(dateTimeString)
  const hours = date.getHours().toString().padStart(2, '0')
  const minutes = date.getMinutes().toString().padStart(2, '0')
  return `${hours}:${minutes}`
}

// ログ一覧を取得
const fetchLogs = async () => {
  if (!authStore.loggedIn || !authStore.family) return

  loadingLogs.value = true
  logsError.value = null

  try {
    const today = new Date().toISOString().split('T')[0] // YYYY-MM-DD形式
    const { data, error } = await apiFetchAction<LogsResponse>(
      `/api/v1/family/logs?date=${today}`,
      {
        method: 'GET',
      }
    )

    if (error.value) {
      logsError.value = 'ログの取得に失敗しました'
      console.error('Failed to fetch logs:', error.value)
      return
    }

    if (data.value) {
      logs.value = data.value.logs
    }
  } catch (e) {
    logsError.value = 'ログの取得に失敗しました'
    console.error('Failed to fetch logs:', e)
  } finally {
    loadingLogs.value = false
  }
}

// 当日の累計ポイントを取得
const fetchTodayPoints = async () => {
  if (!authStore.loggedIn) return

  try {
    const { data, error } = await apiFetchAction<TodayPointsResponse>(
      '/api/v1/family/points/today',
      {
        method: 'GET',
      }
    )

    if (error.value) {
      console.error('Failed to fetch today points:', error.value)
      return
    }

    if (data.value) {
      todayPoints.value = data.value.today_points
    }
  } catch (e) {
    console.error('Failed to fetch today points:', e)
  }
}

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}

// ページ読み込み時にログイン状態を確認し、データを取得
onMounted(async () => {
  await authStore.checkLoginStatus()
  checkingAuth.value = false

  if (authStore.loggedIn) {
    await Promise.all([fetchLogs(), fetchTodayPoints()])
  }
})
</script>
