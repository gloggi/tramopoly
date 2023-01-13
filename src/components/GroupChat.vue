<template>
  <chat-window
    height="100%"
    :current-user-id="userId"
    :rooms-list-opened="!singleRoom"
    room-id="1"
    :rooms="[{ roomId: '1', roomName: operatorName, users: [] }]"
    :messages="messagesWithInitialMessage"
    :message-actions="[{ name: 'replyMessage', title: 'Antwortä' }]"
    :text-messages="translations"
    messages-loaded
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
    <template #paperclip-icon>
      <o-icon icon="image"></o-icon>
    </template>
  </chat-window>
</template>

<script>
import ChatWindow from '@/vue-advanced-chat/src/lib/ChatWindow.vue'
import { useUserSession } from '@/stores/userSession'
import { useOperator } from '@/composables/useOperator'

export default {
  name: 'GroupChat',
  components: { ChatWindow },
  props: {
    singleRoom: { type: Boolean, default: false },
    groupId: { type: Number, required: true },
    initMessage: { type: String, default: 'Willkommä bim Tramopoly-Chät.' },
    messages: { type: Array, default: () => [] },
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
      TYPE_MESSAGE: 'Schriib öppis netts...',
      SEARCH: 'Suächä',
      IS_ONLINE: 'isch online',
      LAST_SEEN: 'zletscht gsee am ',
      IS_TYPING: 'schriibt...',
      CANCEL_SELECT_MESSAGE: 'Abbrächä',
    },
    messagesLoaded: false,
  }),
  computed: {
    operatorName() {
      return useOperator(this.groupId).operatorName
    },
    messagesWithInitialMessage() {
      if (!this.messagesLoaded) return []
      return [
        {
          _id: '0',
          senderId: '0',
          system: true,
          content: this.initMessage,
          date: new Date().toDateString(),
          created_at: new Date(),
        },
        ...this.messages,
      ]
    },
  },
  methods: {
    fetchMessages() {
      setTimeout(() => {
        this.messagesLoaded = true
      })
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
      // TODO persist to supabase
      if (files) {
        for (let index = 0; index < files.length; index++) {
          // TODO persist files to supabase
          //  await this.uploadFile({ file: files[index], messageId: id, roomId })
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
