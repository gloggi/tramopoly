import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'
import { Profile } from '@/stores/profiles'

export class Abteilung {
  constructor(data) {
    this.id = data.id
    this.name = data.name
    this.active = data.active
    this.logoUrl = data.logo_url
    this.operatorId = data.operator_id
    this.operator = data.operator ? new Profile(data.operator) : null
  }
}

export const useAbteilungen = (options = {}) =>
  useCollectionStore('abteilungen', (data) => new Abteilung(data), options)()

export const useAbteilung = (
  id,
  options = { select: '*,operator:operator_id(*)' }
) => useEntryStore('abteilungen', (data) => new Abteilung(data), options)(id)
