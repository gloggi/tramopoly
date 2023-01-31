<template>
  <vue-advanced-chat
    height="100%"
    :current-user-id="userId"
    :rooms-list-opened="false"
    :room-id="`${groupId}`"
    :rooms="[{ roomId: '1', roomName, users: [] }]"
    :messages="messagesWithStaticMessages"
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
  </vue-advanced-chat>
</template>

<script>
import VueAdvancedChat from '@/vue-advanced-chat/src/lib/ChatWindow.vue'
import { useUserSession } from '@/stores/userSession'
import { useOperator } from '@/composables/useOperator'
import { useCurrentMrT } from '@/composables/useCurrentMrT'
import MrTShouldCallNotification from '@/components/MrTShouldCallNotification'
import useMessageSending from '@/composables/useMessageSending'
import { computed } from 'vue'

export default {
  name: 'GroupChat',
  components: { MrTShouldCallNotification, VueAdvancedChat },
  props: {
    groupId: { type: Number, required: true },
    initMessage: { type: String, default: 'Willkommä bim Tramopoly-Chät.' },
    messages: { type: Array, default: () => [] },
    messagesLoaded: { type: Boolean, default: false },
  },
  data: () => {
    const userSession = useUserSession()
    return {
      userId: userSession.userId,
      userName: userSession.user?.scoutName,
      translations: {
        ROOMS_EMPTY: 'Kei Rüüm',
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
      },
    }
  },
  computed: {
    roomName() {
      return useOperator(this.groupId).operatorName
    },
    mrTShouldCallOperatorMessage() {
      const { isCurrentMrT, mrTShouldCallOperator } = useCurrentMrT()
      if (!(isCurrentMrT(this.groupId) && mrTShouldCallOperator.value))
        return []
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
    },
    messagesWithStaticMessages() {
      return [
        {
          _id: '0',
          senderId: '0',
          system: true,
          content: this.initMessage,
          date: new Date().toDateString(),
          created_at: new Date(),
        },
        ...this.mrTShouldCallOperatorMessage,
        ...this.messages,
        ...this.mrTShouldCallOperatorMessage,
      ]
    },
  },
  methods: {
    fetchMessages(...args) {
      this.$emit('fetch-messages', ...args)
    },
    sendMessage(args) {
      useMessageSending(
        computed(() => this.groupId),
        this.userId,
        this.userName
      ).sendMessage(args)
    },
  },
}
</script>
