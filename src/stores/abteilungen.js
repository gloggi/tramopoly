import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'

export class Abteilung {
  constructor(data) {
    this.id = data.id
    this.name = data.name
    this.active = data.active
  }
}

export const useAbteilungen = (options = {}) =>
  useCollectionStore('abteilungen', (data) => new Abteilung(data), options)()

export const useAbteilung = useEntryStore(
  'abteilungen',
  (data) => new Abteilung(data)
)
