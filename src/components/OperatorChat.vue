<template>
  <vue-advanced-chat
    height="100%"
    :current-user-id="userId"
    :loading-rooms="loading"
    :rooms-loaded="!loading"
    :rooms="rooms"
    :messages="messages"
    :message-actions="[{ name: 'replyMessage', title: 'Antwortä' }]"
    :text-messages="translations"
    :messages-loaded="messagesLoaded"
    textarea-action-enabled
    :show-new-messages-divider="false"
    :show-emojis="false"
    :show-reaction-emojis="false"
    :show-audio="false"
    :show-add-room="false"
    :user-tags-enabled="false"
    accepted-files="image/*"
    @fetch-messages="fetchMessages"
    @fetch-room="(clickedRoom) => (groupId = clickedRoom)"
    @send-message="sendMessage"
    v-bind="$attrs"
  >
    <template v-for="(idx, name) in $slots" #[name]="data">
      <slot :name="name" v-bind="data" />
    </template>
    <template #message_mr-t-should-call-operator>
      <mr-t-should-call-notification></mr-t-should-call-notification>
    </template>
    <template #paperclip-icon>
      <o-icon icon="image"></o-icon>
    </template>
    <template
      v-for="stationVisit in stationVisits"
      #[`message_${stationVisit.id}`]
      :key="stationVisit.id"
    >
      <station-visit-message
        v-if="groupId !== null"
        :station-visit="stationVisit"
        :group-id="groupId"
        is-operator
      ></station-visit-message>
    </template>
    <template
      v-for="jokerVisit in jokerVisits"
      #[`message_${jokerVisit.id}`]
      :key="jokerVisit.id"
    >
      <joker-visit-message
        v-if="groupId !== null"
        :joker-visit="jokerVisit"
        :group-id="groupId"
        is-operator
      ></joker-visit-message>
    </template>
    <template #custom-action-icon>
      <o-icon icon="subway"></o-icon>
    </template>
  </vue-advanced-chat>
</template>

<script setup>
import VueAdvancedChat from '@/vue-advanced-chat/src/lib/ChatWindow.vue'
import { useUserSession } from '@/stores/userSession'
import { useGroups } from '@/stores/groups'
import { computed, ref } from 'vue'
import { storeToRefs } from 'pinia'
import { useChatContents } from '@/stores/chatContent'
import MrTShouldCallNotification from '@/components/MrTShouldCallNotification'
import StationVisitMessage from '@/components/StationVisitMessage'
import JokerVisitMessage from '@/components/JokerVisitMessage'

const { userId, user } = useUserSession()

const translations = {
  ROOMS_EMPTY: 'Kei Gruppänä',
  ROOM_EMPTY: 'Kein Ruum usgwählt',
  NEW_MESSAGES: 'Neui Nachrichtä',
  MESSAGE_DELETED: 'Nachricht isch glöscht wordä',
  MESSAGES_EMPTY: 'Kei Nachrichtä',
  CONVERSATION_STARTED: '',
  TYPE_MESSAGE: 'Schrib öppis netts...',
  SEARCH: 'Suächä',
  IS_ONLINE: 'isch online',
  LAST_SEEN: 'zletscht gsee am ',
  IS_TYPING: 'schribt...',
  CANCEL_SELECT_MESSAGE: 'Abbrächä',
}

const groupsStore = useGroups()
groupsStore.subscribe()
const { loading, all: groups } = storeToRefs(groupsStore)
const rooms = computed(() => {
  return groups.value.map((group) => ({
    roomId: group.id,
    roomName: group.name,
    avatar: group.abteilung.logoUrl,
    users: [
      ...(group.operatorId === userId
        ? [{ id: userId, username: user.scoutName }]
        : []),
    ],
  }))
})

const messagesLoaded = ref(true)
const chatContentsStore = ref(null)
const groupId = ref(null)

async function fetchMessages({ room }) {
  groupId.value = room.roomId
  messagesLoaded.value = false
  chatContentsStore.value = useChatContents(room.roomId)
  chatContentsStore.value.subscribe()
  const moreToLoad = await chatContentsStore.value.fetchMore()
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

async function sendMessage({ content, files, replyMessage }) {
  const message = {
    _id: crypto.randomUUID(),
    senderId: this.userId,
    content,
    created_at: new Date(),
    timestamp: new Date(),
    date: new Date().toDateString(),
  }
  if (files) {
    message.files = formattedFiles(files)
  }
  if (replyMessage) {
    message.replyMessage = {
      _id: replyMessage._id,
      content: replyMessage.content,
      senderId: replyMessage.senderId,
    }
    if (replyMessage.files) {
      message.replyMessage.files = replyMessage.files
    }
  }
  this.$emit('addMessage', message)
}
function formattedFiles(files) {
  const formattedFiles = []
  files.forEach((file) => {
    const messageFile = {
      name: file.name,
      size: file.size,
      type: file.type,
      extension: file.extension || file.type,
      url: file.url || file.localUrl,
    }
    formattedFiles.push(messageFile)
  })
  return formattedFiles
}
</script>

<script>
export default {
  name: 'OperatorChat',
  props: {
    messages: { type: Array, default: () => [] },
    messagesLoaded: { type: Boolean, default: false },
  },
}
</script>
