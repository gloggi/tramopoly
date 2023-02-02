<template>
  <vue-advanced-chat
    ref="chat"
    height="100%"
    :current-user-id="String(userId)"
    :loading-rooms="loadingGroups"
    :rooms-list-opened="isOperator"
    :room-id="String(groupId)"
    :rooms-loaded="!loadingGroups"
    :rooms="JSON.stringify(rooms)"
    rooms-order="asc"
    :messages="JSON.stringify(messages)"
    :username-options="JSON.stringify({ minUsers: 0 })"
    :message-actions="
      JSON.stringify([{ name: 'replyMessage', title: 'Antwortä' }])
    "
    :text-messages="JSON.stringify(translations)"
    :messages-loaded="messagesLoaded"
    textarea-action-enabled
    :show-new-messages-divider="false"
    :show-audio="false"
    :show-add-room="false"
    :user-tags-enabled="false"
    accepted-files="image/*, video/*"
    @fetch-messages="fetchMessages($event.detail[0])"
    @fetch-room="() => (groupId = $event.detail[0].room)"
    @send-message="sendMessage($event.detail[0])"
    @send-message-reaction="sendMessageReaction($event.detail[0])"
    @textarea-action-handler="() => (modalOpen = true)"
    v-bind="$attrs"
  >
    <div v-for="(idx, name) in $slots" :slot="name" :key="idx">
      <slot :name="name" />
    </div>
    <div slot="message_mr-t-should-call-operator">
      <mr-t-should-call-notification></mr-t-should-call-notification>
    </div>
    <div slot="paperclip-icon">
      <o-icon icon="image"></o-icon>
    </div>
    <div slot="custom-action-icon">
      <o-icon icon="subway"></o-icon>
    </div>
    <div
      v-for="stationVisit in stationVisits"
      :slot="`message_${stationVisit.id}`"
      :key="stationVisit.id"
    >
      <station-visit-message
        v-if="groupId !== null"
        :station-visit="stationVisit"
        :group-id="groupId"
        :is-operator="isOperator"
      ></station-visit-message>
    </div>
    <div
      v-for="jokerVisit in jokerVisits"
      :slot="`message_${jokerVisit.id}`"
      :key="jokerVisit.id"
    >
      <joker-visit-message
        v-if="groupId !== null"
        :joker-visit="jokerVisit"
        :group-id="groupId"
        :is-operator="isOperator"
      ></joker-visit-message>
    </div>
  </vue-advanced-chat>
  <visit-modal
    v-if="groupId"
    v-model:active="modalOpen"
    :group-id="groupId"
  ></visit-modal>
</template>

<script setup>
import { useUserSession } from '@/stores/userSession'
import { onMounted, onUnmounted, ref, toRefs } from 'vue'
import MrTShouldCallNotification from '@/components/MrTShouldCallNotification'
import StationVisitMessage from '@/components/StationVisitMessage'
import JokerVisitMessage from '@/components/JokerVisitMessage'
import useMessageSending from '@/composables/useMessageSending'
import VisitModal from '@/components/VisitModal'
import useMessageReading from '@/composables/useMessageReading'
import useChatRooms from '@/composables/useChatRooms'
import { register as registerVueAdvancedChatWebComponent } from 'vue-advanced-chat'

registerVueAdvancedChatWebComponent()

const props = defineProps({
  isOperator: { type: Boolean, default: false },
  initialGroupId: { type: Number, required: false },
  loadingGroups: { type: Boolean, default: false },
  groups: { type: Array, required: true },
  initMessage: { type: String, required: false },
})
const { isOperator, initialGroupId, loadingGroups, groups, initMessage } =
  toRefs(props)

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

const { userId, user } = useUserSession()

const groupId = ref(initialGroupId.value)
const modalOpen = ref(false)

const { rooms } = useChatRooms(groups, isOperator, user)
const {
  messagesLoaded,
  fetchMessages,
  messages,
  stationVisits,
  jokerVisits,
  clearChatContentCache,
} = useMessageReading(groupId, isOperator, initMessage)
const { sendMessage, sendMessageReaction } = useMessageSending(
  groupId,
  userId,
  user.scoutName
)

const chat = ref(null)

onMounted(() => {
  if (chat.value) {
    const style = document.createElement('style')
    style.type = 'text/css'
    style.innerHTML =
      '.vac-room-header .vac-rotate-icon {\n' +
      '  transform: rotate(0) !important;\n' +
      '}\n' +
      '.vac-message-wrapper .vac-card-system {\n' +
      '  max-width: 1024px;\n' +
      '}'
    chat.value.shadowRoot.appendChild(style)
  }
})

onUnmounted(() => {
  clearChatContentCache()
})
</script>

<script>
export default {
  name: 'GroupChat',
}
</script>
