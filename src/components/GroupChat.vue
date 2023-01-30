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
    accepted-files="image/*"
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

export default {
  name: 'GroupChat',
  components: { MrTShouldCallNotification, VueAdvancedChat },
  props: {
    groupId: { type: Number, required: true },
    initMessage: { type: String, default: 'Willkommä bim Tramopoly-Chät.' },
    messages: { type: Array, default: () => [] },
    messagesLoaded: { type: Boolean, default: false },
  },
  data: () => ({
    userId: useUserSession().userId,
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
  }),
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
    async sendMessage({ content, files, replyMessage }) {
      const message = {
        _id: crypto.randomUUID(),
        senderId: this.userId,
        content,
        created_at: new Date(),
        timestamp: new Date(),
        date: new Date().toDateString(),
      }
      if (files) {
        message.files = this.formattedFiles(files)
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
    },
    formattedFiles(files) {
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
    },
  },
}
</script>
