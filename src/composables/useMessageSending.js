import { useGroup } from '@/stores/groups'
import slugify from 'slugify'
import { supabase } from '@/client'
import { showAlert } from '@/utils'
import useFileCompression from './useFileCompression'

export default function useMessageSending(groupId, userId, username) {
  const { getCompressedImageUrl } = useFileCompression()

  async function sendMessage({ content, files, replyMessage }) {
    const message = {
      _id: crypto.randomUUID(),
      senderId: userId,
      content,
      created_at: new Date(),
      timestamp: new Date(),
      date: new Date().toDateString(),
    }
    if (files) {
      message.files = await formattedFiles(files)
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
    addMessage(message)
  }

  async function formattedFiles(files) {
    return Promise.all(files.map((file) => {
      return new Promise(async (resolve, reject) => {
        const messageFile = {
          name: file.name,
          size: file.size,
          type: file.type,
          extension: file.extension || file.type,
          url: await getCompressedImageUrl(file),
        }
        resolve(messageFile)
      })
    }))
  }

  async function addMessage(message) {
    try {
      const uploadedFiles = await Promise.all(
        (message.files || []).map(async (file) => {
          const timestamp = new Date().toISOString()
          const groupName = useGroup(groupId.value).entry?.name || groupId.value
          const extension = file.extension
          const filename = slugify(
            `${timestamp}-${groupName}-${username}`
          ).substring(0, 62 - extension.length)
          const { data, error } = await supabase.storage
            .from('messageFiles')
            .upload(
              `${filename}.${extension}`,
              await (await fetch(file.url)).blob(),
              { contentType: file.type }
            )
          if (error) throw error
          return data.path
        })
      )
      const { error } = await supabase.rpc('post_message', {
        content: message.content,
        file_paths: uploadedFiles,
        reply_message_id: message.replyMessage?._id || null,
        group_id: groupId.value,
      })
      if (error) throw error
    } catch (error) {
      console.log(error)
      showAlert(
        'Öppis isch schiäf gangä. Probiär mal d Sitä neu z ladä und dä Stations- odär Jokärbsuäch nomal z erfassä.'
      )
    }
  }

  async function sendMessageReaction({ messageId, reaction, remove }) {
    await supabase.rpc('post_message_reaction', {
      message_id: messageId,
      reaction: reaction.unicode,
      mode: remove ? 'remove' : 'add',
    })
  }

  return { sendMessage, sendMessageReaction }
}
