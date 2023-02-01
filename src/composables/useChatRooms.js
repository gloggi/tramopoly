import { computed } from 'vue'
import { useProfiles } from '@/stores/profiles'
import { storeToRefs } from 'pinia'

export default function useChatRooms(groups, isOperator, user) {
  function sortIndexForGroup(group) {
    const isOwnGroup = group.abteilung?.operatorId === user.id ? '0' : '9'
    const abteilung = group.abteilung?.name
    return `${isOwnGroup}-${abteilung}-${group.name}`
  }

  const rooms = computed(() => {
    return groups.value
      .filter((group) => isOperator.value || group.id === user.groupId)
      .map((group) => ({
        index: sortIndexForGroup(group),
        roomId: String(group.id),
        roomName: group.name,
        avatar: group.abteilung.logoUrl,
        users: usersFor(group.id, group.operatorId),
      }))
  })

  const usersStore = useProfiles({ select: 'id,scout_name,group_id' })
  usersStore.subscribe()
  const { all: users } = storeToRefs(usersStore)

  function usersFor(roomId, operatorId) {
    return users.value
      .filter((user) => user.groupId === roomId || user.id === operatorId)
      .map((user) => ({
        _id: user.id,
        username:
          user.scoutName + (user.groupId === roomId ? '' : ` (Zentralä)`),
      }))
  }

  return { rooms }
}
