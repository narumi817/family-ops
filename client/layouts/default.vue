<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-pink-50 to-yellow-50">
    <!-- ヘッダーナビゲーション -->
    <header class="relative z-50 bg-white shadow-md border-b border-orange-100">
      <div class="container mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <!-- ロゴ -->
          <NuxtLink to="/" class="flex items-center space-x-2" @click="closeMobileMenu">
            <BrandLogo />
          </NuxtLink>

          <!-- タブレット以上: 大項目＋ホバーでサブメニュー -->
          <nav
            class="hidden md:flex items-center gap-1 lg:gap-2"
            aria-label="メインメニュー"
          >
            <!-- 1. ダッシュボード（単体リンク） -->
            <NuxtLink
              to="/"
              class="rounded-full px-3 py-2 text-sm font-medium text-gray-700 ring-1 ring-transparent hover:bg-gray-50 hover:ring-gray-200 transition-colors"
              @mouseenter="closeDesktopMenuNow"
            >
              ダッシュボード
            </NuxtLink>

            <!-- 2. ログ（ホバーで開く。常に1つだけ開く／クリックでフォーカスが残っても他へホバーで切り替わる） -->
            <div
              class="relative"
              @mouseenter="openDesktopMenu('log')"
              @mouseleave="scheduleCloseDesktopMenu"
            >
              <button
                type="button"
                class="flex items-center gap-0.5 rounded-full px-3 py-2 text-sm font-medium text-gray-700 ring-1 ring-transparent hover:bg-gray-50 hover:ring-gray-200 transition-colors"
                :aria-expanded="desktopMenuOpen === 'log'"
                aria-haspopup="true"
              >
                ログ
                <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              <div
                v-show="desktopMenuOpen === 'log'"
                class="absolute left-0 top-full z-50 pt-1"
              >
                <div class="min-w-[12rem] rounded-xl border border-orange-100 bg-white py-1 shadow-lg">
                  <NuxtLink
                    to="/logs/new"
                    class="block px-4 py-2.5 text-sm text-gray-700 hover:bg-orange-50 hover:text-orange-700"
                    @click="closeDesktopMenuNow"
                  >
                    ログを記録
                  </NuxtLink>
                </div>
              </div>
            </div>

            <!-- 3. タスク -->
            <div
              v-if="authStore.family"
              class="relative"
              @mouseenter="openDesktopMenu('tasks')"
              @mouseleave="scheduleCloseDesktopMenu"
            >
              <button
                type="button"
                class="flex items-center gap-0.5 rounded-full px-3 py-2 text-sm font-medium text-gray-700 ring-1 ring-transparent hover:bg-gray-50 hover:ring-gray-200 transition-colors"
                :aria-expanded="desktopMenuOpen === 'tasks'"
                aria-haspopup="true"
              >
                タスク
                <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              <div
                v-show="desktopMenuOpen === 'tasks'"
                class="absolute left-0 top-full z-50 pt-1"
              >
                <div class="min-w-[12rem] rounded-xl border border-orange-100 bg-white py-1 shadow-lg">
                  <NuxtLink
                    :to="`/families/${authStore.family.id}/tasks`"
                    class="block px-4 py-2.5 text-sm text-gray-700 hover:bg-orange-50 hover:text-orange-700"
                    @click="closeDesktopMenuNow"
                  >
                    タスク・ポイント
                  </NuxtLink>
                </div>
              </div>
            </div>

            <!-- 4. 家族・メンバー -->
            <div
              v-if="authStore.family"
              class="relative"
              @mouseenter="openDesktopMenu('family')"
              @mouseleave="scheduleCloseDesktopMenu"
            >
              <button
                type="button"
                class="flex items-center gap-0.5 rounded-full px-3 py-2 text-sm font-medium text-gray-700 ring-1 ring-transparent hover:bg-gray-50 hover:ring-gray-200 transition-colors"
                :aria-expanded="desktopMenuOpen === 'family'"
                aria-haspopup="true"
              >
                家族・メンバー
                <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              <div
                v-show="desktopMenuOpen === 'family'"
                class="absolute left-0 top-full z-50 pt-1"
              >
                <div class="min-w-[12rem] rounded-xl border border-orange-100 bg-white py-1 shadow-lg">
                  <NuxtLink
                    :to="`/families/${authStore.family.id}/invitations/new`"
                    class="block px-4 py-2.5 text-sm text-gray-700 hover:bg-orange-50 hover:text-orange-700"
                    @click="closeDesktopMenuNow"
                  >
                    家族を招待
                  </NuxtLink>
                </div>
              </div>
            </div>

            <!-- 5. アカウント -->
            <div
              class="relative"
              @mouseenter="openDesktopMenu('account')"
              @mouseleave="scheduleCloseDesktopMenu"
            >
              <button
                type="button"
                class="flex items-center gap-0.5 rounded-full px-3 py-2 text-sm font-medium text-gray-700 ring-1 ring-transparent hover:bg-gray-50 hover:ring-gray-200 transition-colors"
                :aria-expanded="desktopMenuOpen === 'account'"
                aria-haspopup="true"
              >
                アカウント
                <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              <div
                v-show="desktopMenuOpen === 'account'"
                class="absolute right-0 top-full z-50 pt-1"
              >
                <div class="min-w-[12rem] rounded-xl border border-orange-100 bg-white py-1 shadow-lg">
                  <button
                    type="button"
                    class="block w-full px-4 py-2.5 text-left text-sm text-gray-700 hover:bg-orange-50 hover:text-orange-700"
                    @click="openHelpFromDesktop"
                  >
                    使い方を見る
                  </button>
                  <button
                    type="button"
                    class="block w-full px-4 py-2.5 text-left text-sm text-gray-700 hover:bg-orange-50 hover:text-orange-700"
                    @click="handleLogout"
                  >
                    ログアウト
                  </button>
                </div>
              </div>
            </div>
          </nav>

          <!-- スマホ: ヘルプ（?）＋ハンバーガー -->
          <div class="flex items-center gap-1 md:hidden">
            <button
              type="button"
              class="inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-full border border-gray-200 text-sm font-semibold text-gray-500 hover:border-orange-300 hover:text-orange-500"
              aria-label="使い方ヘルプ"
              @click="showHelp = true"
            >
              ?
            </button>
            <button
              type="button"
              class="inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-lg border border-gray-200 text-gray-600 hover:border-orange-300 hover:bg-orange-50 hover:text-orange-600"
              :aria-expanded="mobileMenuOpen"
              aria-controls="mobile-nav-menu"
              aria-label="メニューを開く"
              @click="mobileMenuOpen = !mobileMenuOpen"
            >
              <span class="sr-only">{{ mobileMenuOpen ? 'メニューを閉じる' : 'メニューを開く' }}</span>
              <svg
                v-if="!mobileMenuOpen"
                class="h-5 w-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                aria-hidden="true"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
              <svg
                v-else
                class="h-5 w-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                aria-hidden="true"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        <!-- スマホ: ハンバーガー内＝大項目＋タップでサブを開く（アコーディオン） -->
        <div
          v-show="mobileMenuOpen"
          id="mobile-nav-menu"
          class="absolute left-0 right-0 top-full z-50 max-h-[min(70vh,calc(100dvh-5rem))] overflow-y-auto border-b border-orange-100 bg-white shadow-lg md:hidden"
        >
          <nav class="container mx-auto flex flex-col px-2 py-2" aria-label="メインメニュー">
            <NuxtLink
              to="/"
              class="rounded-lg px-3 py-3 text-sm font-medium text-gray-800 hover:bg-orange-50"
              @click="closeMobileMenu"
            >
              ダッシュボード
            </NuxtLink>

            <!-- ログ -->
            <div class="border-t border-orange-50">
              <button
                type="button"
                class="flex w-full items-center justify-between rounded-lg px-3 py-3 text-left text-sm font-medium text-gray-800 hover:bg-orange-50"
                :aria-expanded="mobileSection === 'log'"
                @click="toggleMobileSection('log')"
              >
                ログ
                <svg
                  class="h-4 w-4 shrink-0 text-gray-400 transition-transform"
                  :class="{ 'rotate-180': mobileSection === 'log' }"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  aria-hidden="true"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              <div v-show="mobileSection === 'log'" class="border-l-2 border-orange-200 pb-2 pl-4 ml-3">
                <NuxtLink
                  to="/logs/new"
                  class="block rounded-lg py-2 pr-3 text-sm text-gray-600 hover:text-orange-600"
                  @click="closeMobileMenu"
                >
                  ログを記録
                </NuxtLink>
              </div>
            </div>

            <!-- タスク -->
            <div v-if="authStore.family" class="border-t border-orange-50">
              <button
                type="button"
                class="flex w-full items-center justify-between rounded-lg px-3 py-3 text-left text-sm font-medium text-gray-800 hover:bg-orange-50"
                :aria-expanded="mobileSection === 'tasks'"
                @click="toggleMobileSection('tasks')"
              >
                タスク
                <svg
                  class="h-4 w-4 shrink-0 text-gray-400 transition-transform"
                  :class="{ 'rotate-180': mobileSection === 'tasks' }"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  aria-hidden="true"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              <div v-show="mobileSection === 'tasks'" class="border-l-2 border-orange-200 pb-2 pl-4 ml-3">
                <NuxtLink
                  :to="`/families/${authStore.family.id}/tasks`"
                  class="block rounded-lg py-2 pr-3 text-sm text-gray-600 hover:text-orange-600"
                  @click="closeMobileMenu"
                >
                  タスク・ポイント
                </NuxtLink>
              </div>
            </div>

            <!-- 家族・メンバー -->
            <div v-if="authStore.family" class="border-t border-orange-50">
              <button
                type="button"
                class="flex w-full items-center justify-between rounded-lg px-3 py-3 text-left text-sm font-medium text-gray-800 hover:bg-orange-50"
                :aria-expanded="mobileSection === 'family'"
                @click="toggleMobileSection('family')"
              >
                家族・メンバー
                <svg
                  class="h-4 w-4 shrink-0 text-gray-400 transition-transform"
                  :class="{ 'rotate-180': mobileSection === 'family' }"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  aria-hidden="true"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              <div v-show="mobileSection === 'family'" class="border-l-2 border-orange-200 pb-2 pl-4 ml-3">
                <NuxtLink
                  :to="`/families/${authStore.family.id}/invitations/new`"
                  class="block rounded-lg py-2 pr-3 text-sm text-gray-600 hover:text-orange-600"
                  @click="closeMobileMenu"
                >
                  家族を招待
                </NuxtLink>
              </div>
            </div>

            <!-- アカウント -->
            <div class="border-t border-orange-50">
              <button
                type="button"
                class="flex w-full items-center justify-between rounded-lg px-3 py-3 text-left text-sm font-medium text-gray-800 hover:bg-orange-50"
                :aria-expanded="mobileSection === 'account'"
                @click="toggleMobileSection('account')"
              >
                アカウント
                <svg
                  class="h-4 w-4 shrink-0 text-gray-400 transition-transform"
                  :class="{ 'rotate-180': mobileSection === 'account' }"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  aria-hidden="true"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              <div v-show="mobileSection === 'account'" class="border-l-2 border-orange-200 pb-2 pl-4 ml-3">
                <button
                  type="button"
                  class="block w-full rounded-lg py-2 pr-3 text-left text-sm text-gray-600 hover:text-orange-600"
                  @click="openHelpAndCloseMenu"
                >
                  使い方を見る
                </button>
                <button
                  type="button"
                  class="block w-full rounded-lg py-2 pr-3 text-left text-sm text-gray-600 hover:text-orange-600"
                  @click="handleLogoutFromMenu"
                >
                  ログアウト
                </button>
              </div>
            </div>
          </nav>
        </div>
      </div>
    </header>

    <!-- メインコンテンツ -->
    <main class="container mx-auto px-4 py-8">
      <slot />
    </main>

    <!-- 使い方モーダル -->
    <HelpGuideModal v-if="showHelp" @close="showHelp = false" />
  </div>
</template>

<script setup lang="ts">
import HelpGuideModal from '~/components/organisms/HelpGuideModal.vue'
import BrandLogo from '~/components/atoms/BrandLogo.vue'

const authStore = useAuthStore()
const router = useRouter()
const route = useRoute()

type DesktopMenuKey = 'log' | 'tasks' | 'family' | 'account'

const showHelp = ref(false)
const mobileMenuOpen = ref(false)
/** スマホ: 開いているアコーディオン（null = すべて閉じ） */
const mobileSection = ref<'log' | 'tasks' | 'family' | 'account' | null>(null)

/** PC: 開いているドロップダウン（同時に1つだけ） */
const desktopMenuOpen = ref<DesktopMenuKey | null>(null)
let desktopMenuCloseTimer: ReturnType<typeof setTimeout> | null = null

const openDesktopMenu = (key: DesktopMenuKey) => {
  if (desktopMenuCloseTimer !== null) {
    clearTimeout(desktopMenuCloseTimer)
    desktopMenuCloseTimer = null
  }
  desktopMenuOpen.value = key
}

/** メニュー外へ出たあと少し遅らせて閉じる（隣の項目へ移動するときのちらつき防止） */
const scheduleCloseDesktopMenu = () => {
  if (desktopMenuCloseTimer !== null) {
    clearTimeout(desktopMenuCloseTimer)
  }
  desktopMenuCloseTimer = setTimeout(() => {
    desktopMenuOpen.value = null
    desktopMenuCloseTimer = null
  }, 120)
}

const closeDesktopMenuNow = () => {
  if (desktopMenuCloseTimer !== null) {
    clearTimeout(desktopMenuCloseTimer)
    desktopMenuCloseTimer = null
  }
  desktopMenuOpen.value = null
}

const openHelpFromDesktop = () => {
  showHelp.value = true
  closeDesktopMenuNow()
}

onBeforeUnmount(() => {
  if (desktopMenuCloseTimer !== null) {
    clearTimeout(desktopMenuCloseTimer)
  }
})

const closeMobileMenu = () => {
  mobileMenuOpen.value = false
  mobileSection.value = null
}

const toggleMobileSection = (id: 'log' | 'tasks' | 'family' | 'account') => {
  mobileSection.value = mobileSection.value === id ? null : id
}

const openHelpAndCloseMenu = () => {
  showHelp.value = true
  closeMobileMenu()
}

const handleLogout = async () => {
  closeDesktopMenuNow()
  closeMobileMenu()
  await authStore.logout()
  router.push('/login')
}

const handleLogoutFromMenu = async () => {
  await handleLogout()
}

watch(
  () => route.fullPath,
  () => {
    closeDesktopMenuNow()
    closeMobileMenu()
  }
)

// 認証チェック
onMounted(async () => {
  await authStore.checkLoginStatus()
  if (!authStore.loggedIn) {
    router.push('/login')
  }
})
</script>
