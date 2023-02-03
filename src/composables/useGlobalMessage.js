import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useSettings } from '@/stores/settings.js'

export default function useGlobalMessage() {
  const settingsStore = useSettings()
  settingsStore.subscribe()
  const { entry: settings } = storeToRefs(settingsStore)

  const messageTitle = computed(() => settings.value?.messageTitle)
  const messageText = computed(() => settings.value?.messageText)
  const messageType = computed(() => settings.value?.messageType)

  return { messageTitle, messageText, messageType }
}
