import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'

export class Profile {
  constructor(data) {
    this.id = data.id
    this.scoutName = data.scout_name
    this.groupId = data.group_id
    this.phone = data.phone
    this.busy = data.busy
  }
}

export const useProfiles = (options = {}) =>
  useCollectionStore('profiles', (data) => new Profile(data), options)()

export const useProfile = (id, options = {}) =>
  useEntryStore('profiles', (data) => new Profile(data), options)(id)
