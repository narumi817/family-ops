// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: ['@pinia/nuxt', '@nuxtjs/tailwindcss'],
  runtimeConfig: {
    public: {
      // Render では API_HOST と API_PORT から BASE_URL を構築
      // 開発環境では BASE_URL を直接指定可能
      baseURL: process.env.BASE_URL || (() => {
        const host = process.env.API_HOST
        const port = process.env.API_PORT
        if (host && port) {
          // Render のサービスは HTTPS でアクセス
          // port が 443 の場合は省略、それ以外は :port を付ける
          const portPart = port === '443' ? '' : `:${port}`
          return `https://${host}${portPart}`
        }
        return 'http://localhost:3000'
      })(),
    },
  },
  nitro: {
    devProxy: {
      '/api': {
        target: process.env.BASE_URL || (() => {
          const host = process.env.API_HOST
          const port = process.env.API_PORT
          if (host && port) {
            const portPart = port === '443' ? '' : `:${port}`
            return `https://${host}${portPart}`
          }
          return 'http://localhost:3000'
        })(),
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

