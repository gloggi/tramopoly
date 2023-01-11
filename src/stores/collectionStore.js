import { defineStore } from 'pinia'
import { supabase } from '@/client'

function applyFilterToQuery(query, filter) {
  if (!filter) return query
  return Object.entries(filter).reduce((query, [operator, args]) => {
    if (!query.operator || typeof query.operator !== 'function') {
      const key = operator
      const value = args
      return query.eq(key, value)
    }
    return query[operator](...args)
  }, query)
}

export const useCollectionStore = (
  table,
  wrapperCallback = (data) => data,
  { initialData = undefined, select = '*', filter = null }
) => {
  const storeId = [table, 'all', select, JSON.stringify(filter)].join('-')
  return defineStore(storeId, {
    state: () => ({ data: initialData, subscribed: false }),
    getters: {
      loading: (state) => state.data === undefined,
      all: (state) =>
        typeof state.data?.map === 'function'
          ? state.data.map((entry) => wrapperCallback(entry, state.subscribed))
          : [],
    },
    actions: {
      subscribe() {
        this.subscribed = true
        supabase
          .channel('public:' + table)
          .on('postgres_changes', { event: '*', schema: 'public', table }, () =>
            this.fetch(true)
          )
          .subscribe()
        return this.fetch()
      },
      async fetch(forceReload = false) {
        if (this.data && !forceReload) return
        const query = supabase.from(table).select(select)
        const { data } = await applyFilterToQuery(query, filter)
        this.data = data
      },
    },
  })
}
