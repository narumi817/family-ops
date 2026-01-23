export const useApi = () => {
  const config = useRuntimeConfig()
  const baseURL = config.public.baseURL

  // コンポーネントマウント時やsetup内で使用（useFetch）
  const apiFetch = <T>(url: string, options: any = {}) => {
    return useFetch<T>(url, {
      baseURL,
      ...options,
      credentials: 'include', // Cookie認証のために必要
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    })
  }

  // イベントハンドラ内で使用（$fetch）
  const apiFetchAction = async <T>(url: string, options: any = {}): Promise<{ data: Ref<T | null>; error: Ref<any> }> => {
    try {
      const data = await $fetch<T>(url, {
        baseURL,
        ...options,
        credentials: 'include', // Cookie認証のために必要
        headers: {
          'Content-Type': 'application/json',
          ...options.headers,
        },
      })
      return {
        data: ref(data),
        error: ref(null),
      }
    } catch (err: any) {
      return {
        data: ref(null),
        error: ref({
          data: err.data || err,
          statusCode: err.statusCode || err.status,
        }),
      }
    }
  }

  return {
    apiFetch,
    apiFetchAction,
  }
}


