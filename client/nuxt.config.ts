// https://nuxt.com/docs/api/configuration/nuxt-config
function getBaseURL(): string {
  // 開発環境では BASE_URL が直接指定されていればそれを使用
  if (process.env.BASE_URL) {
    return process.env.BASE_URL
  }

  // Render 環境では API_HOST と API_PORT から構築
  const host = process.env.API_HOST
  const port = process.env.API_PORT

  if (host && port) {
    // Render のサービスは https://<service-name>.onrender.com 形式
    // host がサービス名のみの場合は .onrender.com を追加
    let fullHost = host
    if (!host.includes('.')) {
      fullHost = `${host}.onrender.com`
    }
    
    // 外部アクセスは HTTPS でポート443（省略可能）
    // ただし、port が 443 以外の場合は明示的に指定
    if (port === '443' || port === '80') {
      return `https://${fullHost}`
    }
    return `https://${fullHost}:${port}`
  }

  // デフォルト（開発環境）
  return 'http://localhost:3000'
}

export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: ['@pinia/nuxt', '@nuxtjs/tailwindcss'],
  runtimeConfig: {
    public: {
      baseURL: getBaseURL(),
    },
  },
  nitro: {
    devProxy: {
      '/api': {
        target: getBaseURL(),
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

