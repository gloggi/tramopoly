import { Abteilung, useAbteilung } from '@/stores/abteilungen'
import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'

class Group {
  constructor(data) {
    this.id = data.id
    this.name = data.name
    this.abteilungId = data.abteilung_id

    if (data.abteilung) {
      this._abteilung = new Abteilung(data.abteilung)
    } else {
      this._abteilungStore = useAbteilung(this.abteilungId)
    }
  }

  get abteilung() {
    if (this._abteilung) return this._abteilung

    this._abteilungStore.fetch()
    return this._abteilungStore.entry
  }
}

export const useGroups = (options = {}) =>
  useCollectionStore('groups', (data) => new Group(data), options)()

export const useGroup = useEntryStore('groups', (data) => new Group(data))
