import { computed } from 'vue'
import { useProfiles } from '@/stores/profiles.js'

export function useGroupMembers(groupId) {
  const membersStore = computed(() => {
    const store = useProfiles({
      filter: { group_id: groupId.value },
    })
    store.subscribe()
    return store
  })

  const groupMembers = computed(() => {
    return membersStore.value.all
  })

  return { groupMembers }
}
