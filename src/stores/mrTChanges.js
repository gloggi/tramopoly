import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'

export class MrTChange {
  constructor(data, subscribe) {
    this.id = data.id
    this.createdAt = data.created_at ? new Date(data.created_at) : null
    this._subscribed = subscribe
  }
}

export const useMrTChanges = (options = {}) => {
  return useCollectionStore(
    'mr_t_changes',
    (data, subscribe) => new MrTChange(data, subscribe),
    options,
    (entry) => useStationVisit(entry.id, { ...options, initialData: entry })
  )()
}

export const useStationVisit = (id, options = {}) =>
  useEntryStore(
    'mr_t_changes',
    (data, subscribe) => new MrTChange(data, subscribe),
    options
  )(id)
