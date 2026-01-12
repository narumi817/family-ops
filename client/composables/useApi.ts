export const useApi = () => {
  const config = useRuntimeConfig()
  const baseURL = config.public.baseURL

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

  return {
    apiFetch,
  }
}


