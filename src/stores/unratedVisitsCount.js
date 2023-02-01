import { defineStore } from 'pinia'
import { supabase } from '@/client'

export const useUnratedVisitsCount = () => {
  const subscribeToTable = (table, callback) => {
    supabase
      .channel(`unratedVisitsCount-${table}`)
      .on('postgres_changes', { event: '*', schema: 'public', table }, callback)
      .subscribe()
  }

  return defineStore('unratedVisitsCount', {
    state: () => ({
      data: undefined,
      subscribed: false,
      fetching: false,
    }),
    getters: {
      loading: (state) => state.data === undefined,
      counts() {
        if (this.loading) return {}
        return Object.fromEntries(
          this.data.map(
            ({ group_id, unrated_station_visits, unrated_joker_visits }) => [
              group_id,
              unrated_station_visits + unrated_joker_visits,
            ]
          )
        )
      },
    },
    actions: {
      subscribe() {
        if (this.subscribed) return
        this.subscribed = true
        subscribeToTable('joker_visits', () => this.fetch(true))
        subscribeToTable('station_visits', () => this.fetch(true))
        return this.fetch()
      },
      async fetch(forceReload = false) {
        if (this.fetching || (this.data && !forceReload)) return
        this.fetching = true
        const { data } = await supabase.rpc('unrated_visits_count')
        this.data = data
        this.fetching = false
      },
    },
  })()
}
