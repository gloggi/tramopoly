<template>
  <div class="card">
    <div class="card-content">
      <h3 class="title is-size-3 has-text-weight-semibold">
        Wo isch dä Mr. T?
      </h3>
      <article>
        <p class="is-6 has-text-weight-semibold is-multiline-text">
          {{ lastKnownMrTLocation }}
        </p>
        <p class="is-6">{{ timeSinceLastMrTReport }}</p>
        <p class="is-6">{{ timeSinceLastActiveMrTChange }}</p>
      </article>
      <h3 class="title is-size-3 has-text-weight-semibold mt-4">
        Mr. T Änderig mäldä
      </h3>
      <form @submit.prevent="submit">
        <o-field label="Weli Gruppä hät neu dä Mr. T?">
          <o-select
            v-model="selectedGroupId"
            class="has-text-weight-semibold"
            expanded
            required
          >
            <option
              v-for="option in groups"
              :value="option.id"
              :key="option.id"
            >
              {{ option.name }} ({{ option.abteilung?.name }})
            </option>
          </o-select>
        </o-field>
        <o-field label="Tram / Bus / Zug">
          <o-input type="text" :placeholder="lastMrT.vehicle" v-model="vehicle"
        /></o-field>
        <o-field label="Letschti bekannti Station"
          ><o-autocomplete
            :data="locationsFilteredByLastKnownLocation"
            :placeholder="lastMrT.lastKnownLocation"
            v-model="lastKnownLocation"
            open-on-focus
        /></o-field>
        <o-field label="Richtig"
          ><o-autocomplete
            :data="locationsFilteredByDirection"
            :placeholder="lastMrT.direction"
            v-model="direction"
            open-on-focus
        /></o-field>
        <o-field label="Beschribig"
          ><o-input
            type="textarea"
            :placeholder="lastMrT.description"
            v-model="description"
        /></o-field>
        <button v-if="groupIsCurrentlyMrT" class="button is-link" type="submit">
          Mr T. aktualisiärä
        </button>
        <button v-else class="button is-link is-success" type="submit">
          {{ group.name }} zum Mr T. machä!
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, toRefs } from 'vue'
import { storeToRefs } from 'pinia'
import { useGroups } from '@/stores/groups'
import { useCurrentMrT } from '@/composables/useCurrentMrT'
import useFilteredMrTLocations from '@/composables/useFilteredMrTLocations'
import { supabase } from '@/client'

const props = defineProps({
  groupId: { type: Number, required: true },
})
const { groupId } = toRefs(props)

const groupsStore = useGroups()
const { all: groups } = storeToRefs(groupsStore)
const selectedGroupId = ref(groupId.value)
const vehicle = ref('')
const direction = ref('')
const lastKnownLocation = ref('')
const description = ref('')

const group = computed(() => {
  return groups.value?.find((g) => g.id === selectedGroupId.value) || {}
})

const {
  currentMrT: lastMrT,
  isCurrentMrT,
  lastKnownMrTLocation,
  timeSinceLastMrTReport,
  timeSinceLastActiveMrTChange,
} = useCurrentMrT()
const groupIsCurrentlyMrT = computed(() => isCurrentMrT(selectedGroupId.value))

const { locationsFilteredByLastKnownLocation, locationsFilteredByDirection } =
  useFilteredMrTLocations(lastKnownLocation, direction)

async function submit() {
  await supabase.from('mr_t_changes').insert({
    group_id: groupId.value,
    vehicle: vehicle.value,
    direction: direction.value,
    last_known_location: lastKnownLocation.value,
    description: description.value,
  })
}
</script>

<script>
export default {
  name: 'MrTChangeForm',
}
</script>
