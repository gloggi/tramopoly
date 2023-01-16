import { defineStore } from 'pinia'
import { supabase } from '@/client'
import { useSettings } from '@/stores/settings'

export class GroupBalances {
  constructor(data, t0) {
    this.data = data
    this.t0 = t0
    this._settingsStore = useSettings()
    this._settingsStore.subscribe()
  }

  for(groupId, t = this.t0) {
    const coefficients = this.data?.find(
      (balances) => balances.group_id === groupId
    )
    if (!coefficients || !this._settings()) return 0
    const { c0, c1 } = coefficients
    const { gameStart, gameEnd } = this._settings()
    const secondsSinceCalculationTime =
      (Math.min(Math.max(gameStart, t), gameEnd) - this.t0) / 1000
    return Math.floor(c0 + secondsSinceCalculationTime * c1)
  }

  _settings() {
    return this._settingsStore.entry
  }
}

export const useGroupBalances = () => {
  const subscribeToTable = (table, callback) => {
    supabase
      .channel(`public:${table}`)
      .on('postgres_changes', { event: '*', schema: 'public', table }, callback)
      .subscribe()
  }
  return defineStore('groupBalances', {
    state: () => ({
      data: undefined,
      fetchTime: undefined,
      subscribed: false,
      fetching: false,
    }),
    getters: {
      loading: (state) => state.data === undefined,
      balances: (state) => new GroupBalances(state.data, state.fetchTime),
    },
    actions: {
      subscribe() {
        this.subscribed = true
        subscribeToTable('groups', () => this.fetch(true))
        subscribeToTable('settings', () => this.fetch(true))
        // subscribeToTable('joker_visits', () => this.fetch(true)) // TODO
        subscribeToTable('station_visits', () => this.fetch(true))
        return this.fetch()
      },
      async fetch(forceReload = false) {
        if ((this.fetching || this.data) && !forceReload) return
        this.fetching = true
        this.fetchTime = new Date()
        const { data } = await supabase.rpc('calculate_balance_coeffs', {
          t0: this.fetchTime,
        })
        this.data = data
        this.fetching = false
      },
    },
  })()
}
