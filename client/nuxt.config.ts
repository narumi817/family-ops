// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: ['@pinia/nuxt', '@nuxtjs/tailwindcss'],
  app: {
    head: {
      script: [
        {
          // Microsoft Clarity
          innerHTML:
            '(function(c,l,a,r,i,t,y){c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);})(window, document, "clarity", "script", "vlwk2jlppw");',
        } as any,
      ] as any,
    },
  },
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

