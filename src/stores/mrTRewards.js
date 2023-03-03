import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'

export class MrTReward {
  constructor(data, subscribe) {
    this.id = data.id
    this.duration = data.duration
    this.value = data.value
    this._subscribed = subscribe
  }
}

export const useMrTRewards = (options = {}) => {
  return useCollectionStore(
    'mr_t_rewards',
    (data, subscribe) => new MrTReward(data, subscribe),
    options,
    (entry) => useStationVisit(entry.id, { ...options, initialData: entry })
  )()
}

export const useStationVisit = (id, options = {}) =>
  useEntryStore(
    'mr_t_rewards',
    (data, subscribe) => new MrTReward(data, subscribe),
    options
  )(id)
