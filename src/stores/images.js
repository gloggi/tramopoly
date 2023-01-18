import { defineStore } from 'pinia'
import { supabase } from '@/client'

export const useImages = (bucket, paths) =>
  defineStore(`images-all-${bucket}-${paths}`, {
    state: () => ({ urls: [], fetching: false }),
    getters: {
      loading: (state) => state.urls.length === 0,
    },
    actions: {
      async fetch(forceReload = false) {
        if (!paths.length) return
        if ((this.fetching || this.data) && !forceReload) return
        this.fetching = true
        const { data } = await supabase.storage
          .from(bucket)
          .createSignedUrls(paths, 10 * 60 * 60)
        this.urls = data.map((url) => url.signedUrl)
        paths.forEach((path, index) => {
          // prepare individual stores for each image
          useImage(bucket, path, this.urls[index])
        })
        this.fetching = false
      },
    },
  })()

export const useImage = (
  bucket,
  path,
  initialData = undefined,
  transform = undefined
) => {
  return defineStore(`image-${bucket}-${path}-${JSON.stringify(transform)}`, {
    state: () => ({ url: initialData, fetching: false }),
    getters: {
      loading: (state) => state.url === undefined,
    },
    actions: {
      async fetch(forceReload = false) {
        if ((this.fetching || this.url) && !forceReload) return
        this.fetching = true
        const { data } = await supabase.storage
          .from(bucket)
          .createSignedUrl(path, 10 * 60 * 60, { transform })
        this.url = data.signedUrl
        this.fetching = false
      },
    },
  })()
}
