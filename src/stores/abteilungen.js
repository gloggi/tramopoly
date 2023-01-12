import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'
import { useProfile } from '@/stores/profiles'

export class Abteilung {
  constructor(data, subscribe) {
    this.id = data.id
    this.name = data.name
    this.active = data.active
    this.logoUrl = data.logo_url
    this.operatorId = data.operator_id || data.operator?.id
    this._operatorData = data.operator
    this._subscribed = subscribe
  }

  get operator() {
    if (!this.operatorId) return null
    const operatorStore = useProfile(this.operatorId, {
      initialData: this._operatorData,
    })
    if (this._subscribed) operatorStore.subscribe()
    else operatorStore.fetch()
    return operatorStore.entry
  }
}

export const useAbteilungen = (
  options = { select: '*,operator:operator_id(*)' }
) =>
  useCollectionStore(
    'abteilungen',
    (data, subscribe) => new Abteilung(data, subscribe),
    options
  )()

export const useAbteilung = (
  id,
  options = { select: '*,operator:operator_id(*)' }
) =>
  useEntryStore(
    'abteilungen',
    (data, subscribe) => new Abteilung(data, subscribe),
    options
  )(id)
