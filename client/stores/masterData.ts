import { defineStore } from 'pinia'

export interface RoleOption {
  value: string
  label: string
}

interface MasterDataState {
  roles: RoleOption[]
  loaded: boolean
  loading: boolean
}

export const useMasterDataStore = defineStore('masterData', {
  state: (): MasterDataState => ({
    roles: [],
    loaded: false,
    loading: false,
  }),

  actions: {
    async fetchMasterData() {
      // 既にロード済みなら再取得しない
      if (this.loaded || this.loading) return

      this.loading = true
      try {
        const { apiFetchAction } = useApi()
        const { data, error } = await apiFetchAction<{
          roles: RoleOption[]
        }>('/api/v1/master_data', {
          method: 'GET',
        })

        if (error.value) {
          console.error('Failed to fetch master data:', error.value)
          return
        }

        if (data.value?.roles) {
          this.roles = data.value.roles
          this.loaded = true
        }
      } catch (e) {
        console.error('Failed to fetch master data:', e)
      } finally {
        this.loading = false
      }
    },
  },
})

