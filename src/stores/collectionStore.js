import { defineStore } from 'pinia'
import { supabase } from '@/client'

function filterQuery(query, filter) {
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
  { select = '*', filter = null }
) => {
  const storeId = [table, 'all', select, JSON.stringify(filter)].join('-')
  return defineStore(storeId, {
    state: () => ({ data: undefined }),
    getters: {
      loading: (state) => state.data === undefined,
      all: (state) =>
        typeof state.data?.map === 'function'
          ? state.data.map(wrapperCallback)
          : [],
    },
    actions: {
      subscribe() {
        supabase
          .channel('public:' + table)
          .on('postgres_changes', { event: '*', schema: 'public', table }, () =>
            this.fetch(true)
          )
          .subscribe()
        this.fetch()
      },
      async fetch(forceReload = false) {
        if (this.data && !forceReload) return
        const query = supabase.from(table).select(select)
        const { data } = await filterQuery(query, filter)
        this.data = data
      },
    },
  })
}
