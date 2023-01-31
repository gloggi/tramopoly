<template>
  <vue-advanced-chat
    height="100%"
    :current-user-id="userId"
    :loading-rooms="loadingGroups"
    :rooms-list-opened="isOperator"
    :room-id="String(groupId)"
    :rooms-loaded="!loadingGroups"
    :rooms="rooms"
    :messages="messages"
    :username-options="{ minUsers: 0 }"
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
    accepted-files="image/*, video/*"
    @fetch-messages="fetchMessages"
    @fetch-room="(room) => (groupId = room)"
    @send-message="sendMessage"
    @textarea-action-handler="modalOpen = true"
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
    <template #custom-action-icon>
      <o-icon icon="subway"></o-icon>
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
        :is-operator="isOperator"
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
        :is-operator="isOperator"
      ></joker-visit-message>
    </template>
  </vue-advanced-chat>
  <visit-modal
    v-if="groupId"
    v-model:active="modalOpen"
    :group-id="groupId"
  ></visit-modal>
</template>

<script setup>
import VueAdvancedChat from '@/vue-advanced-chat/src/lib/ChatWindow.vue'
import { useUserSession } from '@/stores/userSession'
import { ref, toRefs } from 'vue'
import MrTShouldCallNotification from '@/components/MrTShouldCallNotification'
import StationVisitMessage from '@/components/StationVisitMessage'
import JokerVisitMessage from '@/components/JokerVisitMessage'
import useMessageSending from '@/composables/useMessageSending'
import VisitModal from '@/components/VisitModal'
import useMessageReading from '@/composables/useMessageReading'
import useChatRooms from '@/composables/useChatRooms'

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
const { messagesLoaded, fetchMessages, messages, stationVisits, jokerVisits } =
  useMessageReading(groupId, isOperator, initMessage)
const { sendMessage } = useMessageSending(groupId, userId, user.scoutName)
</script>

<script>
export default {
  name: 'GroupChat',
}
</script>
