import { defineStore } from 'pinia'
import { supabase } from '@/client'

export const useEntryStore = (table, wrapperCallback = (data) => data) => {
  return (id) =>
    defineStore(`${table}-${id}`, {
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
          this.fetch()
        },
        async fetch(forceReload = false) {
          if (this.data && !forceReload) return
          const { data } = await supabase
            .from(table)
            .select()
            .eq('id', id)
            .single()
          this.data = data
        },
      },
    })()
}
