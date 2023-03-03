<template>
  <div class="column is-full has-text-centered">
    <table v-if="allScoreChanges.length">
      <thead>
        <td>Timestamp</td>
        <td v-for="group in groups" :key="group.id">
          {{ groupNameFor(group) }}
        </td>
      </thead>
      <tr v-for="(scoreChange, i) in allScoreChanges" :key="i">
        <td>{{ new Date(allTimes[i]).valueOf() }}</td>
        <td v-for="group in groups" :key="group.id">
          {{ scoreChange[group.id] }}
        </td>
      </tr>
    </table>
  </div>
</template>

<script setup>
import { useStationVisits } from '@/stores/stationVisits.js'
import { storeToRefs } from 'pinia'
import { useMrTSwitches } from '@/composables/useMrTSwitches.js'
import { computed } from 'vue'
import { useJokerVisits } from '@/stores/jokerVisits.js'
import { useGroupScores } from '@/stores/groupScores.js'
import { useGroups } from '@/stores/groups.js'
import { useSettings } from '@/stores/settings.js'
import { useUserSession } from '@/stores/userSession.js'
import { useRouter } from 'vue-router'

const userSession = useUserSession()
const { isAdmin } = storeToRefs(userSession)

if (!isAdmin.value) {
  const router = useRouter()
  router.replace({ name: 'dashboard' })
}

const settingsStore = useSettings()
settingsStore.fetch()
const gameStart = computed(() => settingsStore.entry.gameStart)
const gameEnd = computed(() => settingsStore.entry.gameEnd)

const stationVisitsStore = useStationVisits()
stationVisitsStore.subscribe()
const { all: stationVisits } = storeToRefs(stationVisitsStore)
const stationVisitTimes = computed(() => {
  return stationVisits.value.map((sv) => sv.createdAt)
})

const jokerVisitsStore = useJokerVisits()
jokerVisitsStore.subscribe()
const { all: jokerVisits } = storeToRefs(jokerVisitsStore)
const jokerVisitsTimes = computed(() => {
  return jokerVisits.value.map((jv) => jv.createdAt)
})

const { mrTSwitches } = useMrTSwitches()
const mrTSwitchesTimes = computed(() => {
  return mrTSwitches.value.map((sw) => sw.createdAt)
})

const allTimes = computed(() => {
  const times = stationVisitTimes.value
    .concat(jokerVisitsTimes)
    .concat(mrTSwitchesTimes)
    .filter((time) => time)
  //.slice(0, 2)
  return times
    .concat(times.map((time) => new Date(time.valueOf() - 1000)))
    .concat([gameStart.value, gameEnd.value])
    .sort()
})

const groups = computed(() => {
  const groupsStore = useGroups()
  groupsStore.fetch()
  return groupsStore.all.sort((a, b) => {
    if (a.abteilungId !== b.abteilungId) return a.abteilungId - b.abteilungId
    return a.name.localeCompare(b.name)
  })
})

function groupNameFor(group) {
  return `${group.name} (${group.abteilung.name})`
}

const allScoreChanges = computed(() => {
  return allTimes.value.map((time) => {
    const groupScoresStore = useGroupScores(time)
    groupScoresStore.fetch()
    return groupScoresStore.staticTotals
  })
})
</script>

<script>
export default {
  name: 'GraphView',
}
</script>
