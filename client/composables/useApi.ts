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
        'Cache-Control': 'no-cache', // キャッシュを無効化
        ...options.headers,
      },
    }) as ReturnType<typeof useFetch<T>>
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
          'Cache-Control': 'no-cache', // キャッシュを無効化
          ...options.headers,
        },
      })
      return {
        data: ref(data as T | null),
        error: ref(null),
      } as { data: Ref<T | null>; error: Ref<any> }
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


