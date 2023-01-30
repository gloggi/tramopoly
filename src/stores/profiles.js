import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'
import { useGroup } from '@/stores/groups'

export class Profile {
  constructor(data, subscribe) {
    this.id = data.id
    this.scoutName = data.scout_name
    this.phone = data.phone
    this.preferredCallMethod = data.preferred_call_method
    this.role = data.role
    this.activeCallerId = data.active_caller_id || data.active_caller?.id
    this._activeCallerData = data.active_caller
    this.groupId = data.group_id || data.group?.id
    this._groupData = data.group
    this._subscribed = subscribe
  }

  get group() {
    if (!this.groupId) return null
    const groupStore = useGroup(this.groupId, {
      initialData: this._groupData,
    })
    if (this._subscribed) groupStore.subscribe()
    else groupStore.fetch()
    return groupStore.entry
  }

  get activeCaller() {
    if (!this.activeCallerId) return null
    const callerStore = useProfile(this.activeCallerId, {
      initialData: this._activeCallerData,
    })
    if (this._subscribed) callerStore.subscribe()
    else callerStore.fetch()
    return callerStore.entry
  }
}

export const useProfiles = (options = {}) =>
  useCollectionStore(
    'profiles',
    (data) => new Profile(data),
    options,
    (entry) => useProfile(entry.id, { ...options, initialData: entry })
  )()

export const useProfile = (id, options = {}) =>
  useEntryStore('profiles', (data) => new Profile(data), options)(id)
