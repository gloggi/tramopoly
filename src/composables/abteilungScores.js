import { useGroupScores } from '@/stores/groupScores'
import { storeToRefs } from 'pinia'
import { useGroups } from '@/stores/groups'
import { useAbteilungen } from '@/stores/abteilungen'
import { computed } from 'vue'

export const useAbteilungScores = () => {
  const groupScoresStore = useGroupScores()
  groupScoresStore.subscribe()
  const { balances, interestRates, realEstatePoints, mrTPoints, totals } =
    storeToRefs(groupScoresStore)

  const groupsStore = useGroups({ filter: { active: true } })
  groupsStore.subscribe()
  const { all: groups } = storeToRefs(groupsStore)

  const abteilungenStore = useAbteilungen({ filter: { active: true } })
  abteilungenStore.subscribe()
  const { all: abteilungen } = storeToRefs(abteilungenStore)

  const groupsByAbteilung = computed(() => {
    return Object.fromEntries(
      abteilungen.value.map((abteilung) => [
        abteilung.id,
        groups.value.filter((group) => group.abteilungId === abteilung.id),
      ])
    )
  })

  function averageScore(groups, scores) {
    if (groups.length === 0) return 0
    return (
      groups
        .map((group) => scores.value[group.id])
        .reduce((sum, score) => sum + score, 0) / groups.length
    )
  }

  const averageBalancesByAbteilung = computed(() => {
    return Object.fromEntries(
      Object.entries(groupsByAbteilung.value).map(([abteilungId, groups]) => [
        abteilungId,
        averageScore(groups, balances),
      ])
    )
  })

  const averageInterestRatesByAbteilung = computed(() => {
    return Object.fromEntries(
      Object.entries(groupsByAbteilung.value).map(([abteilungId, groups]) => [
        abteilungId,
        averageScore(groups, interestRates),
      ])
    )
  })

  const averageRealEstatePointsByAbteilung = computed(() => {
    return Object.fromEntries(
      Object.entries(groupsByAbteilung.value).map(([abteilungId, groups]) => [
        abteilungId,
        averageScore(groups, realEstatePoints),
      ])
    )
  })

  const averageMrTPointsByAbteilung = computed(() => {
    return Object.fromEntries(
      Object.entries(groupsByAbteilung.value).map(([abteilungId, groups]) => [
        abteilungId,
        averageScore(groups, mrTPoints),
      ])
    )
  })

  const averageTotalsByAbteilung = computed(() => {
    return Object.fromEntries(
      Object.entries(groupsByAbteilung.value).map(([abteilungId, groups]) => [
        abteilungId,
        averageScore(groups, totals),
      ])
    )
  })

  return {
    averageBalancesByAbteilung,
    averageInterestRatesByAbteilung,
    averageRealEstatePointsByAbteilung,
    averageMrTPointsByAbteilung,
    averageTotalsByAbteilung,
  }
}
