import { defineStore } from 'pinia'
import { supabase } from '@/client'

export const useEntryStore = (
  table,
  wrapperCallback = (data) => data,
  { select = '*', ...otherOptions }
) => {
  return (id) => {
    const self = () =>
      useEntryStore(table, wrapperCallback, {
        select,
        ...otherOptions,
      })(id)
    return defineStore(`${table}-${id}-${select}`, {
      state: () => ({ data: undefined }),
      getters: {
        loading: (state) => state.data === undefined,
        entry: (state) => (state.data ? wrapperCallback(state.data) : null),
      },
      actions: {
        subscribe() {
          supabase
            .channel(`public:${table}:id=eq.${id}`)
            .on(
              'postgres_changes',
              {
                event: '*',
                schema: 'public',
                table: table,
                filter: 'id=eq.' + id,
              },
              () => this.fetch(true)
            )
            .subscribe()
          return this.fetch()
        },
        fetch(forceReload = false) {
          if (this.data && !forceReload) return self()
          supabase
            .from(table)
            .select(select)
            .eq('id', id)
            .single()
            .then(({ data }) => (this.data = data))
          return self()
        },
      },
    })()
  }
}
