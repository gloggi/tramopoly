import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'
import { useImage, useImages } from '@/stores/images'
import { useProfile } from '@/stores/profiles'

export class Message {
  constructor(data, subscribe) {
    this.id = data.id
    this.createdAt = data.created_at ? new Date(data.created_at) : null
    this.senderId = data.sender_id || data.sender?.id
    this._senderData = data.sender
    this.content = data.content
    this.groupId = data.group_id
    this.replyMessageId = data.reply_message_id || data.reply_message?.id
    this._replyMessageData = data.reply_message
    this.files = (data.message_files || []).map(
      (file) => new MessageFile(file, subscribe)
    )
    this._subscribed = subscribe
  }

  get sender() {
    if (!this.senderId) return null
    const profileStore = useProfile(this.senderId, {
      initialData: this._senderData,
    })
    if (this._subscribed) profileStore.subscribe()
    else profileStore.fetch()
    return profileStore.entry
  }

  get replyMessage() {
    if (!this.replyMessageId) return null
    const replyMessageStore = useMessage(this.replyMessageId, {
      initialData: this._replyMessageData,
      select: '*,message_files(*),sender:sender_id(*)',
    })
    if (this._subscribed) replyMessageStore.subscribe()
    else replyMessageStore.fetch()
    return replyMessageStore.entry
  }

  toChatFormat() {
    return {
      _id: this.id,
      senderId: this.senderId ? String(this.senderId) : undefined,
      content: this.content,
      username:
        this.sender?.scoutName +
        (this.sender?.groupId === this.groupId ? '' : ' (Zentralä)'),
      createdAt: this.createdAt,
      timestamp: this.createdAt.toString().substring(16, 21),
      date: this.createdAt.toDateString(),
      files: this.files.map((file) => file.toChatFormat()),
      replyMessage: this.replyMessage?.toChatFormat(),
    }
  }
}

export class MessageFile {
  constructor(data) {
    this.id = data.id
    this.createdAt = data.created_at ? new Date(data.created_at) : null
    this._filePath = data.file_path
    this.messageId = data.message_id
  }

  get url() {
    if (!this._filePath) return null
    const imageStore = useImage('messageFiles', this._filePath)
    imageStore.fetch()
    return imageStore.url
  }

  toChatFormat() {
    const filename = this._filePath?.split('/').pop()
    const extension = filename.split('.').pop()
    const type = extension
    return {
      name: filename,
      type,
      extension,
      url: this.url || '',
      audio:
        extension.toLowerCase() in ['mp3', 'wav', 'aiff', 'aif', 'ogg', 'm4a'],
    }
  }
}

export const useMessages = (
  options = {
    select:
      '*,message_files(*),sender:sender_id(*),reply_message:reply_message_id(*,message_files(*),sender:sender_id(*))',
  }
) => {
  const store = useCollectionStore(
    'messages',
    (data, subscribe) => new Message(data, subscribe),
    options,
    (entry) => useMessage(entry.id, { ...options, initialData: entry })
  )()
  store.$subscribe((mutation, state) => {
    if (!state.data) return
    useImages(
      'messageFiles',
      state.data
        .flatMap((message) => message.message_files?.file_path)
        .filter((filePath) => filePath)
    ).fetch()
  })
  return store
}

export const useMessage = (
  id,
  options = {
    select:
      '*,message_files(*),sender:sender_id(*),reply_message:reply_message_id(*,message_files(*),sender:sender_id(*))',
  }
) =>
  useEntryStore(
    'messages',
    (data, subscribe) => new Message(data, subscribe),
    options
  )(id)
