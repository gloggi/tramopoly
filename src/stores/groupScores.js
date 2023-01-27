import { defineStore } from 'pinia'
import { supabase } from '@/client'
import { useSettings } from '@/stores/settings'
import { gsap } from 'gsap'

export const useGroupScores = () => {
  const subscribeToTable = (table, callback) => {
    supabase
      .channel(`public:${table}`)
      .on('postgres_changes', { event: '*', schema: 'public', table }, callback)
      .subscribe()
  }

  const settingsStore = useSettings()
  settingsStore.subscribe()

  const timeline = gsap.timeline()

  return defineStore('groupScores', {
    state: () => ({
      data: undefined,
      t0: undefined,
      subscribed: false,
      fetching: false,
      balances: {},
      interestRates: {},
      realEstatePoints: {},
      mrTPoints: {},
      refreshTimeout: null,
    }),
    getters: {
      loading: (state) => state.data === undefined || settingsStore.loading,
      totals: (state) =>
        Object.fromEntries(
          Object.keys(state.balances).map((key) => [
            key,
            state.balances[key] +
              state.realEstatePoints[key] +
              state.mrTPoints[key],
          ])
        ),
    },
    actions: {
      subscribe() {
        this.subscribed = true
        subscribeToTable('abteilungen', () => this.fetch(true))
        subscribeToTable('groups', () => this.fetch(true))
        subscribeToTable('settings', () => this.fetch(true))
        subscribeToTable('mr_t_rewards', () => this.fetch(true))
        subscribeToTable('joker_visits', () => this.fetch(true))
        subscribeToTable('station_visits', () => this.fetch(true))
        subscribeToTable('mr_t_changes', () => this.fetch(true))
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
        this.data.forEach((entry) => {
          if (this.balances[entry.group_id] === undefined) {
            this.balances[entry.group_id] = 0
            this.interestRates[entry.group_id] = 0
            this.realEstatePoints[entry.group_id] = 0
            this.mrTPoints[entry.group_id] = 0
          }
        })
        if (this.refreshTimeout) clearTimeout(this.refreshTimeout)
        if (data && data.length) {
          this.t0 = data[0].t0 ? new Date(data[0].t0) : null
          if (data[0].invalid_after) {
            // Refresh once the current scores are known to be outdated
            this.refreshTimeout = setTimeout(
              () => this.fetch(true),
              new Date(data[0].invalid_after) - Date.now() + 3000
            )
          }
        }
        this._animate(2)
      },
      _animate(seconds) {
        const commonTweenVars = {
          duration: seconds,
          ease: 'linear',
          snap: this.data.map((entry) => entry.group_id).join(','),
          ...this._calculateAllAt(new Date().valueOf() + seconds * 1000),
        }
        timeline
          .clear()
          .to(this.balances, {
            ...commonTweenVars,
            onComplete: () => this._animate(Math.min(4, 2 * seconds)),
            ...this._calculateAllAt(new Date().valueOf() + seconds * 1000),
          })
          .to(
            this.interestRates,
            {
              ...commonTweenVars,
              ...Object.fromEntries(
                this.data.map(({ group_id, c1 }) => [group_id, c1 * 60])
              ),
            },
            0
          )
          .to(
            this.realEstatePoints,
            {
              ...commonTweenVars,
              ...Object.fromEntries(
                this.data.map(({ group_id, real_estate_points }) => [
                  group_id,
                  real_estate_points,
                ])
              ),
            },
            0
          )
          .to(
            this.mrTPoints,
            {
              ...commonTweenVars,
              ...Object.fromEntries(
                this.data.map(({ group_id, mr_t_points }) => [
                  group_id,
                  mr_t_points,
                ])
              ),
            },
            0
          )
      },
      _calculateAllAt(t) {
        if (settingsStore.loading) {
          return Object.fromEntries(
            this.data.map(({ group_id }) => [group_id, 0])
          )
        }
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
