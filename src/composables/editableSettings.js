import { useSettings } from '@/stores/settings'
import { computed } from 'vue'
import { debounce } from '@/utils'
import { supabase } from '@/client'

export function useEditableSettings() {
  const settingsStore = useSettings()
  settingsStore.subscribe()

  const settingsId = computed(() => settingsStore.entry?.id)

  const setGameStart = async (value) => {
    console.log('setting start', value)
    await supabase
      .from('settings')
      .update({ game_start: value })
      .eq('id', settingsId.value)
  }
  const gameStart = computed({
    get() {
      return settingsStore.entry?.gameStart
    },
    set: debounce(setGameStart, 1000),
  })

  const setGameEnd = async (value) => {
    await supabase
      .from('settings')
      .update({ game_end: value })
      .eq('id', settingsId.value)
  }
  const gameEnd = computed({
    get() {
      return settingsStore.entry?.gameEnd
    },
    set: debounce(setGameEnd, 1000),
  })

  const setStartTimeToNow = () => setGameStart(new Date())
  const setEndTimeToNow = () => setGameEnd(new Date())

  return {
    gameStart,
    gameEnd,
    setStartTimeToNow,
    setEndTimeToNow,
  }
}