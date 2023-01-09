import { Abteilung } from '@/stores/abteilungen'
import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'

class Group {
  constructor(data) {
    this.id = data.id
    this.name = data.name
    this.abteilungId = data.abteilung_id
    this.abteilung = data.abteilung ? new Abteilung(data.abteilung) : null
  }
}

export const useGroups = (options = {}) =>
  useCollectionStore('groups', (data) => new Group(data), options)()

export const useGroup = (
  id,
  options = { select: '*,abteilung:abteilungen(*)' }
) => useEntryStore('groups', (data) => new Group(data), options)(id)
