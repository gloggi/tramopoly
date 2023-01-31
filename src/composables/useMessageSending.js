import { useGroup } from '@/stores/groups'
import slugify from 'slugify'
import { supabase } from '@/client'
import { showAlert } from '@/utils'

export default function useMessageSending(groupId, userId, username) {
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
    addMessage(message)
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

  return { sendMessage }
}
