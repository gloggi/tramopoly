import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'

export class Station {
  constructor(data, subscribe) {
    this.id = data.id
    this.name = data.name
    this.value = data.value
    this._subscribed = subscribe
  }
}

export const useStations = (options = { select: '*' }) =>
  useCollectionStore(
    'stations',
    (data, subscribe) => new Station(data, subscribe),
    options
  )()

export const useStation = (id, options = { select: '*' }) =>
  useEntryStore(
    'stations',
    (data, subscribe) => new Station(data, subscribe),
    options
  )(id)
