import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useMrTChanges } from '@/stores/mrTChanges.js'
import { useMrTRewards } from '@/stores/mrTRewards.js'

export function useMrTSwitches() {
  const mrTChangesStore = useMrTChanges()
  mrTChangesStore.fetch()
  const { all: mrTChanges } = storeToRefs(mrTChangesStore)

  const mrTRewardsStore = useMrTRewards()
  mrTRewardsStore.fetch()
  const { all: mrTRewards } = storeToRefs(mrTRewardsStore)

  function rewardFor(duration, change) {
    if (change.deactivated) return 0
    return (
      mrTRewards.value.find((reward) => {
        return reward.duration < duration
      })?.value || 0
    )
  }

  const mrTSwitches = computed(() => {
    return mrTChanges.value.reduce((switches, change) => {
      if (!switches.length) switches.push(change)
      else if (
        switches[switches.length - 1].group_id !== change.group_id ||
        switches[switches.length - 1].disabled !== change.disabled
      ) {
        const previousDuration =
          change.created_at - switches[switches.length - 1].created_at
        switches[switches.length - 1].reward = rewardFor(
          previousDuration,
          switches[switches.length - 1]
        )
        switches.push(change)
      }
      return switches
    }, [])
  })

  return { mrTSwitches }
}
