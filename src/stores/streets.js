import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'

export class Street {
  constructor(data, subscribe) {
    this.id = data.id
    this.name = data.name
    this.value = data.value
    this.color = data.color
    this._subscribed = subscribe
  }
}

export const useStreets = (options = { select: '*' }) =>
  useCollectionStore(
    'streets',
    (data, subscribe) => new Street(data, subscribe),
    options,
    (entry) => useStreet(entry.id, { ...options, initialData: entry })
  )()

export const useStreet = (id, options = { select: '*' }) =>
  useEntryStore(
    'streets',
    (data, subscribe) => new Street(data, subscribe),
    options
  )(id)
