export const useApi = () => {
  const config = useRuntimeConfig()
  const baseURL = config.public.baseURL

  const apiFetch = <T>(url: string, options: any = {}) => {
    return useFetch<T>(url, {
      baseURL,
      ...options,
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


