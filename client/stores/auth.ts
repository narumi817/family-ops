import { defineStore } from 'pinia'

interface User {
  id: number
  name: string
  email: string
}

interface Family {
  id: number
  name: string
}

interface AuthState {
  user: User | null
  family: Family | null
  loggedIn: boolean
  loading: boolean
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    user: null,
    family: null,
    loggedIn: false,
    loading: false,
  }),

  actions: {
    async login(email: string, password: string) {
      this.loading = true
      try {
        const { apiFetch } = useApi()
        const { data, error } = await apiFetch<{
          user: User
          family: Family | null
          logged_in: boolean
        }>('/api/v1/login', {
          method: 'POST',
          body: {
            email,
            password,
          },
        })

        if (error.value) {
          throw new Error(error.value.message || 'ログインに失敗しました')
        }

        if (data.value?.logged_in && data.value?.user) {
          this.user = data.value.user
          this.family = data.value.family || null
          this.loggedIn = true
          return { success: true }
        }

        throw new Error('ログインに失敗しました')
      } catch (error: any) {
        return {
          success: false,
          error: error.message || 'ログインに失敗しました',
        }
      } finally {
        this.loading = false
      }
    },

    async logout() {
      this.loading = true
      try {
        const { apiFetch } = useApi()
        await apiFetch('/api/v1/logout', {
          method: 'DELETE',
        })
      } catch (error) {
        console.error('Logout error:', error)
      } finally {
        this.user = null
        this.family = null
        this.loggedIn = false
        this.loading = false
      }
    },

    async checkLoginStatus() {
      try {
        const { apiFetchAction } = useApi()
        const { data } = await apiFetchAction<{
          user: User
          family: Family | null
          logged_in: boolean
        }>('/api/v1/logged_in', {
          method: 'GET',
        })
        if (data.value?.logged_in && data.value?.user) {
          this.user = data.value.user
          this.family = data.value.family || null
          this.loggedIn = true
        } else {
          this.user = null
          this.family = null
          this.loggedIn = false
        }
      } catch (error) {
        console.error('Check login status error:', error)
        this.user = null
        this.loggedIn = false
      }
    },
  },
})

