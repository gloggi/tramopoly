import { defineStore } from 'pinia'
import { supabase } from '@/client'
import { useSettings } from '@/stores/settings'
import { gsap } from 'gsap'

export const useGroupBalances = () => {
  const subscribeToTable = (table, callback) => {
    supabase
      .channel(`public:${table}`)
      .on('postgres_changes', { event: '*', schema: 'public', table }, callback)
      .subscribe()
  }

  const settingsStore = useSettings()
  settingsStore.subscribe()

  const timeline = gsap.timeline()

  return defineStore('groupBalances', {
    state: () => ({
      data: undefined,
      t0: undefined,
      subscribed: false,
      fetching: false,
      balances: {},
    }),
    getters: {
      loading: (state) => state.data === undefined || settingsStore.loading,
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
      async fetch(forceReload = false, onDone = () => {}) {
        if ((this.fetching || this.data) && !forceReload) return onDone()
        this.fetching = true
        this.t0 = new Date()
        const { data } = await supabase.rpc('calculate_balance_coeffs', {
          t0: this.t0,
        })
        this._setData(data)
        this.fetching = false
        return onDone()
      },
      _setData(data) {
        this.data = data
        if (data && data.length) this.t0 = new Date(data[0].t0)
        this._animate(2)
      },
      _animate(seconds) {
        this.data.forEach((entry) => {
          if (this.balances[entry.group_id] === undefined) {
            this.balances[entry.group_id] = 0
          }
        })
        timeline.clear().to(this.balances, {
          duration: seconds,
          ease: 'linear',
          snap: this.data.map((entry) => entry.group_id).join(','),
          onComplete: () => this._animate(Math.min(4, 2 * seconds)),
          ...this._calculateAll(new Date().valueOf() + seconds * 1000),
        })
      },
      _calculateAll(t) {
        const { gameStart, gameEnd } = settingsStore.entry
        const clampedT = Math.min(Math.max(gameStart, t), gameEnd)
        const secondsSinceT0 = (clampedT - this.t0) / 1000
        return Object.fromEntries(
          this.data.map(({ group_id, c0, c1 }) => [
            group_id,
            Math.floor(c0 + secondsSinceT0 * c1),
          ])
        )
      },
    },
  })()
}
