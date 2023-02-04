import { computed } from 'vue'
import { useProfiles } from '@/stores/profiles'
import { storeToRefs } from 'pinia'
import useUnseenChatActivity from '@/composables/useUnseenChatActivity'

export default function useChatRooms(groups, isOperator, user) {
  const { counts } = useUnseenChatActivity()

  function sortIndexForGroup(group) {
    const isOwnGroup = group.abteilung?.operatorId === user.id ? '0' : '9'
    const abteilung = group.abteilung?.name
    return `${isOwnGroup}-${abteilung}-${group.name}`
  }

  const rooms = computed(() => {
    return groups.value
      .filter((group) => isOperator.value || group.id === user.groupId)
      .map((group) => ({
        roomId: String(group.id),
        roomName: group.name,
        avatar: group.abteilung.logoUrl,
        unreadCount:
          group?.abteilung?.operatorId === user.id || group?.id === user.groupId
            ? counts.value[group.id] || 0
            : 0,
        index: sortIndexForGroup(group),
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
        _id: String(user.id),
        username:
          user.scoutName + (user.groupId === roomId ? '' : ` (Zentralä)`),
      }))
  }

  return { rooms }
}
