import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useSettings } from '@/stores/settings.js'

export default function useMapUrl() {
  const settingsStore = useSettings()
  settingsStore.subscribe()
  const { entry: settings } = storeToRefs(settingsStore)

  const mapUrl = computed(() => settings.value?.mapUrl)

  return { mapUrl }
}
