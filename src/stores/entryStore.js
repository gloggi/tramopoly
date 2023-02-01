import { defineStore } from 'pinia'
import { supabase } from '@/client'

export const useEntryStore = (
  table,
  wrapperCallback = (data) => data,
  { initialData = undefined, select = '*' }
) => {
  return (id) => {
    const storeId = `${table}-${id}-${select}`
    return defineStore(storeId, {
      state: () => ({ data: initialData, subscribed: false, fetching: false }),
      getters: {
        loading: (state) => state.data === undefined,
        entry: (state) =>
          state.data ? wrapperCallback(state.data, state.subscribed) : null,
      },
      actions: {
        subscribe() {
          if (this.subscribed) return
          this.subscribed = true
          supabase
            .channel(storeId)
            .on(
              'postgres_changes',
              {
                event: '*',
                schema: 'public',
                table,
                filter: `id=eq.${id}`,
              },
              () => this.fetch(true)
            )
            .subscribe()
          return this.fetch()
        },
        async fetch(forceReload = false) {
          if (this.fetching || (this.data && !forceReload)) return
          this.fetching = true
          const { data } = await supabase
            .from(table)
            .select(select)
            .eq('id', id)
            .single()
          this.data = data
          this.fetching = false
        },
      },
    })()
  }
}
