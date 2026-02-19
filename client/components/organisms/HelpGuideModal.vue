<template>
  <div
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/40"
    @click="emit('close')"
  >
    <div
      class="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-2xl bg-white p-6 shadow-xl sm:p-8"
      @click.stop
    >
      <!-- ヘッダー -->
      <div class="mb-6 relative flex items-center justify-center">
        <h2 class="text-lg font-semibold text-gray-800 sm:text-xl">
          FamilyOps の使い方
        </h2>
        <button
          type="button"
          class="absolute right-0 inline-flex h-8 w-8 items-center justify-center rounded-full text-gray-400 hover:bg-gray-100 hover:text-gray-600"
          @click="$emit('close')"
        >
          <span class="sr-only">閉じる</span>
          <svg
            class="h-4 w-4"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>
      </div>

      <div class="space-y-8 text-sm text-gray-700 sm:text-base">
        <!-- Step 1: 家族招待 -->
        <section v-if="currentStep === 1">
          <h3 class="mb-2 text-base font-semibold text-gray-800 sm:text-lg">
            1. 家族を招待しましょう
          </h3>
          <p class="mb-3">
            まだ家族メンバーがいない場合は、まず家族を招待して一緒にタスクを共有できるようにしましょう。
          </p>
          <div
            class="rounded-xl border border-dashed border-orange-200 bg-orange-50/60 p-4 sm:p-5"
          >
            <p class="mb-3 text-sm font-medium text-gray-800 sm:text-base">
              ヘッダー右上の「家族を招待」ボタンから招待メールを送れます。
            </p>
            <!-- 簡易イメージ（ヘッダーのナビを再現） -->
            <div
              class="flex items-center justify-between rounded-lg bg-white px-4 py-3 shadow-sm sm:px-5"
            >
              <BrandLogo compact />
              <div class="flex items-center space-x-2 sm:space-x-3">
                <span
                  class="rounded-full px-3 py-1 text-xs font-medium text-gray-600 ring-1 ring-gray-200 sm:text-sm"
                >
                  ダッシュボード
                </span>
                <span
                  class="relative rounded-full px-3 py-1 text-xs font-semibold text-orange-600 ring-2 ring-orange-300/70 sm:text-sm"
                >
                  家族を招待
                  <span
                    class="absolute -top-6 left-1/2 hidden -translate-x-1/2 whitespace-nowrap rounded-full bg-orange-500 px-2 py-0.5 text-[10px] font-semibold text-white sm:block"
                  >
                    ここから家族招待！
                  </span>
                </span>
              </div>
            </div>
          </div>
        </section>

        <!-- Step 2: ログ登録 -->
        <section v-else>
          <h3 class="mb-2 text-base font-semibold text-gray-800 sm:text-lg">
            2. ログを登録して家事・育児を見える化
          </h3>
          <p class="mb-3">
            実行したタスクをログとして登録すると、家族全体の家事・育児の負担がタイムラインで見えるようになります。
          </p>
          <div
            class="rounded-xl border border-dashed border-sky-200 bg-sky-50/60 p-4 sm:p-5"
          >
            <p class="mb-3 text-sm font-medium text-gray-800 sm:text-base">
              「ログを追加」ボタンから、登録画面でタスク・実行時間・メモを入力できます。
            </p>
            <!-- 簡易イメージ（ログタイムラインのイメージ） -->
            <div class="space-y-3 rounded-lg bg-white p-4 shadow-sm sm:p-5">
              <div class="flex items-center justify-between">
                <div class="text-xs font-medium text-gray-500 sm:text-sm">
                  今日のログ
                </div>
                <div
                  class="rounded-full bg-orange-100 px-3 py-1 text-xs font-semibold text-orange-700 sm:text-sm"
                >
                  今日のあなたのポイント: 25pt
                </div>
              </div>
              <div class="space-y-2">
                <div class="flex items-start space-x-3">
                  <div
                    class="mt-1 h-2 w-2 rounded-full bg-sky-400 sm:mt-1.5"
                  />
                  <div class="flex-1">
                    <div class="flex items-center justify-between">
                      <span class="text-sm font-semibold text-gray-800">
                        食器洗い
                      </span>
                      <span class="text-xs text-gray-500">20:30</span>
                    </div>
                    <div class="flex items-center justify-between">
                      <span class="text-xs text-gray-500">
                        実行者: パートナー
                      </span>
                      <span
                        class="rounded-full bg-sky-50 px-2 py-0.5 text-xs font-semibold text-sky-600"
                      >
                        +15pt
                      </span>
                    </div>
                  </div>
                </div>
                <div class="flex items-start space-x-3">
                  <div
                    class="mt-1 h-2 w-2 rounded-full bg-orange-400 sm:mt-1.5"
                  />
                  <div class="flex-1">
                    <div class="flex items-center justify-between">
                      <span class="text-sm font-semibold text-gray-800">
                        おむつ替え
                      </span>
                      <span class="text-xs text-gray-500">09:15</span>
                    </div>
                    <div class="flex items-center justify-between">
                      <span class="text-xs text-gray-500">
                        実行者: あなた
                      </span>
                      <span
                        class="rounded-full bg-orange-50 px-2 py-0.5 text-xs font-semibold text-orange-600"
                      >
                        +10pt
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              <p class="mt-2 text-xs text-gray-500 sm:text-sm">
                ログを貯めていくことで、誰がどれくらい家事・育児をしているかがひと目で分かります。
              </p>
            </div>
          </div>
        </section>
      </div>

      <!-- ページング操作 -->
      <div class="mt-6 flex items-center justify-between">
        <div class="flex items-center space-x-2">
          <button
            type="button"
            class="inline-flex items-center rounded-full border px-3 py-1 text-xs font-medium text-gray-600 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-40 sm:text-sm"
            :disabled="currentStep === 1"
            @click="goPrev"
          >
            <span class="mr-1 text-base leading-none">&lt;</span>
            戻る
          </button>
          <button
            type="button"
            class="inline-flex items-center rounded-full border px-3 py-1 text-xs font-medium text-gray-600 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-40 sm:text-sm"
            :disabled="currentStep === maxStep"
            @click="goNext"
          >
            次へ
            <span class="ml-1 text-base leading-none">&gt;</span>
          </button>
        </div>

        <!-- ステップインジケーター -->
        <div class="flex items-center space-x-2">
          <span
            v-for="step in maxStep"
            :key="step"
            class="h-2 w-2 rounded-full"
            :class="step === currentStep ? 'bg-orange-500' : 'bg-gray-300'"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import BrandLogo from '~/components/atoms/BrandLogo.vue'

const emit = defineEmits<{
  (e: "close"): void
}>()

const currentStep = ref(1)
const maxStep = 2

const goNext = () => {
  if (currentStep.value < maxStep) {
    currentStep.value += 1
  }
}

const goPrev = () => {
  if (currentStep.value > 1) {
    currentStep.value -= 1
  }
}
</script>


