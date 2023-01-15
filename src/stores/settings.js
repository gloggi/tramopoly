import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'

export class Settings {
  constructor(data, subscribe) {
    this.id = data.id
    this.gameEnd = new Date(data.game_end)
    this.interestPeriod = data.interest_period
    this.interestRate = data.interest_rate
    this.messageTitle = data.message_title
    this.messageText = data.message_text
    this.messageType = data.message_type
    this.realEstateValueRatio = data.real_estate_value_ratio
    this.rentRatio = data.rent_ratio
    this.starterCash = data.starter_cash
    this.mrTRewards = (data.mr_t_rewards || []).map(
      (reward) => new MrTReward(reward, subscribe)
    )
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
    this.createdAt = new Date(data.created_at)
    this.duration = data.duration
    this.value = data.value
  }
}

export const useSettings = (
  id,
  options = {
    select: '*',
  }
) =>
  useEntryStore(
    'settings',
    (data, subscribe) => new Settings(data, subscribe),
    options
  )(id)

const useMrTRewards = (options = { select: '*' }) =>
  useCollectionStore(
    'mrTRewards',
    (data, subscribe) => new MrTReward(data, subscribe),
    options
  )()
