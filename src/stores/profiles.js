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
    this.activeCallerId = data.active_caller_id
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
}

export const useProfiles = (options = {}) =>
  useCollectionStore('profiles', (data) => new Profile(data), options)()

export const useProfile = (id, options = {}) =>
  useEntryStore('profiles', (data) => new Profile(data), options)(id)
