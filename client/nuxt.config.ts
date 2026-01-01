// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: ['@pinia/nuxt', '@nuxtjs/tailwindcss'],
  runtimeConfig: {
    public: {
      baseURL: process.env.BASE_URL || 'http://localhost:3000',
    },
  },
  nitro: {
    devProxy: {
      '/api': {
        target: process.env.BASE_URL || 'http://localhost:3000',
        changeOrigin: true,
        prependPath: true,
      },
    },
  },
  // 開発サーバーのポート設定
  devServer: {
    port: 3001,
  },
})

