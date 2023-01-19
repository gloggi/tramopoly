import { useAbteilung } from '@/stores/abteilungen'
import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'

export class Group {
  constructor(data, subscribe) {
    this.id = data.id
    this.name = data.name
    this.active = data.active
    this.abteilungId = data.abteilung_id || data.abteilung?.id
    this._abteilungData = data.abteilung
    this._subscribed = subscribe
  }

  get abteilung() {
    if (!this.abteilungId) return null
    const abteilungStore = useAbteilung(this.abteilungId, {
      initialData: this._abteilungData,
    })
    if (this._subscribed) abteilungStore.subscribe()
    else abteilungStore.fetch()
    return abteilungStore.entry
  }
}

export const useGroups = (
  options = { select: '*,abteilung:abteilungen(*,operator:operator_id(*))' }
) =>
  useCollectionStore(
    'groups',
    (data, subscribe) => new Group(data, subscribe),
    options,
    (entry) => useGroup(entry.id, { ...options, initialData: entry })
  )()

export const useGroup = (
  id,
  options = { select: '*,abteilung:abteilungen(*,operator:operator_id(*))' }
) =>
  useEntryStore(
    'groups',
    (data, subscribe) => new Group(data, subscribe),
    options
  )(id)
