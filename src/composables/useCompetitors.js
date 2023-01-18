import { computed } from 'vue'
import { useGroup } from '@/stores/groups'
import { useGroupScores } from '@/stores/groupScores'

export function useCompetitors(groupId) {
  const groupScoresStore = useGroupScores()

  const ranked = computed(() => {
    return Object.entries(groupScoresStore.totals)
      .filter((entry) => entry[0] !== '_gsap')
      .sort((a, b) => b[1] - a[1])
      .map(([groupId, total]) => ({ groupId: parseInt(groupId), total }))
  })
  const rank = computed(() =>
    ranked.value.findIndex((entry) => entry.groupId === groupId.value)
  )

  const betterGroupId = computed(() => {
    if (rank.value === -1 || rank.value === 0) return null
    return ranked.value[rank.value - 1].groupId
  })
  const betterGroup = computed(() => {
    if (betterGroupId.value === null) return null
    const store = useGroup(betterGroupId.value)
    store.fetch()
    return store.entry
  })
  const betterGroupLoading = computed(() => {
    if (betterGroupId.value === null) return null
    const store = useGroup(betterGroupId.value)
    store.fetch()
    return store.loading
  })

  const worseGroupId = computed(() => {
    if (rank.value === -1 || rank.value === ranked.value.length - 1) return null
    return ranked.value[rank.value + 1].groupId
  })
  const worseGroup = computed(() => {
    if (worseGroupId.value === null) return null
    const store = useGroup(worseGroupId.value)
    store.fetch()
    return store.entry
  })
  const worseGroupLoading = computed(() => {
    if (worseGroupId.value === null) return null
    const store = useGroup(worseGroupId.value)
    store.fetch()
    return store.loading
  })

  return {
    betterGroupId,
    betterGroup,
    betterGroupLoading,
    worseGroupId,
    worseGroup,
    worseGroupLoading,
  }
}
