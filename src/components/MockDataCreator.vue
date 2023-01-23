<template>
  <o-button @click="addMockStationVisit">
    Zuefällige Stationsbsuäch hinzuäfüägä
  </o-button>
  <o-button @click="addMockJokerVisit">
    Zuefällige Jokärbsuäch hinzuäfüägä
  </o-button>
</template>

<script setup>
import { supabase } from '@/client'
import { useSettings } from '@/stores/settings'
import { useGroups } from '@/stores/groups'
import { useStations } from '@/stores/stations'
import { useJokers } from '@/stores/jokers'

const settingsStore = useSettings()
settingsStore.subscribe()

const groupsStore = useGroups({ filter: { active: true } })
groupsStore.subscribe()

const stationsStore = useStations()
stationsStore.subscribe()

const jokersStore = useJokers()
jokersStore.subscribe()

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

function randomJoker() {
  return jokersStore.all[Math.floor(Math.random() * jokersStore.all.length)]
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

async function addMockJokerVisit() {
  const randomTime = randomTimeInGame()
  const joker = randomJoker()
  const bonusValues = [
    null,
    0,
    0.5 * joker.bonusCallValue,
    joker.bonusCallValue,
  ]

  await supabase.from('joker_visits').insert({
    created_at: randomTime,
    group_id: randomGroup().id,
    joker_id: joker.id,
    accepted_at: randomTime,
    earned_bonus_value:
      bonusValues[Math.floor(Math.random() * bonusValues.length)],
  })
}
</script>

<script>
export default {
  name: 'MockDataCreator',
}
</script>
