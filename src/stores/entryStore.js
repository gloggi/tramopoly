import { defineStore } from 'pinia'
import { supabase } from '@/client'

export const useEntryStore = (
  table,
  wrapperCallback = (data) => data,
  { initialData = undefined, select = '*' }
) => {
  return (id) => {
    return defineStore(`${table}-${id}-${select}`, {
      state: () => ({ data: initialData, subscribed: false }),
      getters: {
        loading: (state) => state.data === undefined,
        entry: (state) =>
          state.data ? wrapperCallback(state.data, state.subscribed) : null,
      },
      actions: {
        subscribe() {
          this.subscribed = true
          supabase
            .channel(`public:${table}:id=eq.${id}`)
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
          if (this.data && !forceReload) return
          const { data } = await supabase
            .from(table)
            .select(select)
            .eq('id', id)
            .single()
          this.data = data
        },
      },
    })()
  }
}
