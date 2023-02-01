import { defineStore } from 'pinia'
import { supabase } from '@/client'

export function applyFilterToQuery(query, filter) {
  if (!filter) return query
  return Object.entries(filter).reduce((query, [operator, args]) => {
    if (!query[operator] || typeof query[operator] !== 'function') {
      const key = operator
      const value = args
      return query.eq(key, value)
    } else if (Symbol.iterator in Object(args)) {
      return query[operator](...args)
    }
    return query
  }, query)
}

export const useCollectionStore = (
  table,
  wrapperCallback = (data) => data,
  { initialData = undefined, select = '*', filter = null },
  entryStoreFactory = null
) => {
  const storeId = [table, 'all', select, JSON.stringify(filter)].join('-')
  return defineStore(storeId, {
    state: () => ({ data: initialData, subscribed: false, fetching: false }),
    getters: {
      loading: (state) => state.data === undefined,
      all: (state) =>
        typeof state.data?.map === 'function'
          ? state.data.map((entry) => wrapperCallback(entry, state.subscribed))
          : [],
    },
    actions: {
      subscribe() {
        if (this.subscribed) return
        this.subscribed = true
        supabase
          .channel(storeId)
          .on('postgres_changes', { event: '*', schema: 'public', table }, () =>
            this.fetch(true)
          )
          .subscribe()
        return this.fetch()
      },
      async fetch(forceReload = false) {
        if (this.fetching || (this.data && !forceReload)) return
        this.fetching = true
        const query = supabase.from(table).select(select)
        const { data } = await applyFilterToQuery(query, filter)
        this.data = data
        if (entryStoreFactory && data.length) {
          data.forEach((entry) => entryStoreFactory(entry))
        }
        this.fetching = false
      },
    },
  })
}
