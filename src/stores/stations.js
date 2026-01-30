import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'
import { useStreet } from './streets'

export class Station {
  constructor(data, subscribe) {
    this.id = data.id
    this.name = data.name
    this.value = data.value
    this.x = data.x
    this.y = data.y
    this.streetId = data.street_id || data.street?.id
    this._streetData = data.street
    this._subscribed = subscribe
  }

  get street() {
    if (!this.streetId) return null
    const streetStore = useStreet(this.streetId, {
      initialData: this._streetData,
    })
    if (this._subscribed) streetStore.subscribe()
    else streetStore.fetch()
    return streetStore.entry
  }
}

export const useStations = (options = { select: '*,street:street_id(*)' }) =>
  useCollectionStore(
    'stations',
    (data, subscribe) => new Station(data, subscribe),
    options,
    (entry) => useStation(entry.id, { ...options, initialData: entry })
  )()

export const useStation = (id, options = { select: '*' }) =>
  useEntryStore(
    'stations',
    (data, subscribe) => new Station(data, subscribe),
    options
  )(id)
