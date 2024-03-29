import { computed, ref } from 'vue'
import { useChatContents } from '@/stores/chatContent'
import { useCurrentMrT } from '@/composables/useCurrentMrT'
import useUnseenChatActivity from '@/composables/useUnseenChatActivity.js'
import useGlobalMessage from '@/composables/useGlobalMessage.js'

export default function useMessageReading(groupId, isOperator, initMessage) {
  const messagesLoaded = ref(true)

  const { markRoomAsSeen } = useUnseenChatActivity()

  const chatContentsStore = computed(() => {
    const store = useChatContents(groupId.value)
    store.subscribe()
    return store
  })

  async function fetchMessages({ room }) {
    messagesLoaded.value = false
    if (
      isOperator.value &&
      room &&
      groupId.value !== parseInt(room.roomId) &&
      room.roomId !== undefined
    ) {
      groupId.value = parseInt(room.roomId)
      chatContentsStore.value?.$reset()
    }
    markRoomAsSeen(groupId)
    chatContentsStore.value?.subscribe()
    const moreToLoad = await chatContentsStore.value?.fetchMore()
    if (moreToLoad !== undefined) {
      messagesLoaded.value = !moreToLoad
    }
  }

  const messages = computed(() => {
    return chatContentsStore.value?.all
  })
  const stationVisits = computed(() => {
    return chatContentsStore.value?.allStationVisits
  })
  const jokerVisits = computed(() => {
    return chatContentsStore.value?.allJokerVisits
  })

  const mrTShouldCallOperatorMessage = computed(() => {
    const { isCurrentMrT, mrTShouldCallOperator } = useCurrentMrT()
    if (!(isCurrentMrT(groupId.value) && mrTShouldCallOperator.value)) return []
    return [
      {
        _id: 'mr-t-should-call-operator',
        senderId: '0',
        system: true,
        content: '',
        date: new Date().toDateString(),
        created_at: new Date(),
      },
    ]
  })

  const globalMessage = computed(() => {
    const { messageText } = useGlobalMessage()
    if (!messageText.value) return []
    return [
      {
        _id: 'global',
        senderId: '0',
        system: true,
        content: messageText.value,
        date: new Date().toDateString(),
        created_at: new Date(),
      },
    ]
  })

  const initMessageEntry = computed(() => {
    if (!initMessage.value) return []
    return [
      {
        _id: '0',
        senderId: '0',
        system: true,
        content: initMessage.value,
        date: new Date().toDateString(),
        created_at: new Date(),
      },
    ]
  })

  const messagesWithStaticMessages = computed(() => {
    return [
      ...initMessageEntry.value,
      ...messages.value,
      ...mrTShouldCallOperatorMessage.value,
      ...globalMessage.value,
    ]
  })

  function clearChatContentCache() {
    chatContentsStore.value?.$reset()
  }

  return {
    messagesLoaded,
    fetchMessages,
    messages: messagesWithStaticMessages,
    stationVisits,
    jokerVisits,
    clearChatContentCache,
  }
}
