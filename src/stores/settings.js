import { useCollectionStore } from '@/stores/collectionStore'
import { defineStore } from 'pinia'
import { supabase } from '@/client'

export class Settings {
  constructor(data, subscribe) {
    this.id = data.id
    this.gameStart = data.game_start ? new Date(data.game_start) : null
    this.gameEnd = data.game_end ? new Date(data.game_end) : null
    this.interestPeriod = data.interest_period
    this.interestRateStart = data.interest_rate_start
    this.interestRateEnd = data.interest_rate_end
    this.messageTitle = data.message_title
    this.messageText = data.message_text
    this.messageType = data.message_type
    this.realEstateValueRatio = data.real_estate_value_ratio
    this.rentRatio = data.rent_ratio
    this.starterCash = data.starter_cash
    this._subscribed = subscribe
  }

  get mrTRewards() {
    const mrTRewardsStore = useMrTRewards()
    if (this._subscribed) mrTRewardsStore.subscribe()
    else mrTRewardsStore.fetch()
    return mrTRewardsStore.all
  }
}

export class MrTReward {
  constructor(data) {
    this.id = data.id
    this.createdAt = data.created_at ? new Date(data.created_at) : null
    this.duration = data.duration
    this.value = data.value
  }
}

export const useSettings = () =>
  defineStore(`settings`, {
    state: () => ({ data: undefined, subscribed: false, fetching: false }),
    getters: {
      loading: (state) => state.data === undefined,
      entry: (state) =>
        state.data ? new Settings(state.data, state.subscribed) : null,
    },
    actions: {
      subscribe() {
        this.subscribed = true
        supabase
          .channel(`public:settings`)
          .on(
            'postgres_changes',
            { event: '*', schema: 'public', table: 'settings' },
            () => this.fetch(true)
          )
          .subscribe()
        return this.fetch()
      },
      async fetch(forceReload = false) {
        if ((this.fetching || this.data) && !forceReload) return
        this.fetching = true
        const { data } = await supabase.from('settings').select('*').single()
        this.data = data
        this.fetching = false
      },
    },
  })()

const useMrTRewards = (options = { select: '*' }) =>
  useCollectionStore(
    'mrTRewards',
    (data, subscribe) => new MrTReward(data, subscribe),
    options
  )()
