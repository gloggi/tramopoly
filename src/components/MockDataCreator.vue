<template>
  <o-button @click="addMockStationVisit">
    Zuefällige Stationsbsuäch hinzuäfüägä
  </o-button>
</template>

<script setup>
import { supabase } from '@/client'
import { useSettings } from '@/stores/settings'
import { useGroups } from '@/stores/groups'
import { useStations } from '@/stores/stations'

const settingsStore = useSettings()
settingsStore.subscribe()

const groupsStore = useGroups({ filter: { active: true } })
groupsStore.subscribe()

const stationsStore = useStations()
stationsStore.subscribe()

function randomTimeInGame() {
  return new Date(
    settingsStore.entry.gameStart.valueOf() +
      Math.random() *
        (settingsStore.entry.gameEnd - settingsStore.entry.gameStart)
  )
}

function randomGroup() {
  return groupsStore.all[Math.floor(Math.random() * groupsStore.all.length)]
}

function randomStation() {
  return stationsStore.all[Math.floor(Math.random() * stationsStore.all.length)]
}

async function addMockStationVisit() {
  const randomTime = randomTimeInGame()

  await supabase.from('station_visits').insert({
    created_at: randomTime,
    group_id: randomGroup().id,
    station_id: randomStation().id,
    accepted_at: randomTime,
    needs_verification: false,
    verified_at: randomTime,
  })
}
</script>

<script>
export default {
  name: 'MockDataCreator',
}
</script>
