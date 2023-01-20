<template>
  <div class="card" v-if="groups.length">
    <header class="card-header has-background-light">
      <span class="card-header-title title is-4">👩‍👧‍👦 Gruppänä</span>
    </header>
    <o-table
      table-class="has-content-vcentered is-table-layout-fixed"
      :data="groups"
      striped
      hoverable
      default-sort="name"
      :row-class="rowClass"
    >
      <o-table-column #default="{ row }" field="name" label="Namä" sortable>
        <span class="has-text-weight-bold">{{ row.name }}</span>
      </o-table-column>
      <o-table-column
        #default="{ row }"
        field="abteilung.name"
        label="Abteilig"
        sortable
      >
        <span>
          <o-select
            @update:modelValue="(value) => changeAbteilung(row.id, value)"
            :model-value="row.abteilungId"
          >
            <option
              v-for="abteilung in abteilungen"
              :key="abteilung.id"
              :value="abteilung.id"
            >
              {{ abteilung.name }}
            </option>
          </o-select>
        </span>
      </o-table-column>
      <o-table-column
        #default="{ row }"
        field="totalPoints"
        label="Total"
        sortable
        numeric
        :custom-sort="sortByScore(totals)"
      >
        <span>{{ totals[row.id] }}</span>
      </o-table-column>
      <o-table-column
        #default="{ row }"
        field="balance"
        label="Guäthabä"
        sortable
        numeric
        :custom-sort="sortByScore(balances)"
      >
        <div>
          {{ balances[row.id] }}
          <span
            v-if="row.id in interestRates"
            class="tag is-info is-small mb-2 is-valign-middle has-text-weight-bold is-inline-flex"
          >
            +{{ interestRates[row.id] }}.-/min
          </span>
        </div>
      </o-table-column>
      <o-table-column
        #default="{ row }"
        field="realEstatePoints"
        label="Immobiliä"
        sortable
        numeric
        :custom-sort="sortByScore(realEstatePoints)"
        >{{ realEstatePoints[row.id] }}</o-table-column
      >
      <o-table-column
        #default="{ row }"
        field="mrTPoints"
        label="Mr. T"
        sortable
        numeric
        :custom-sort="sortByScore(mrTPoints)"
      >
        <div>
          {{ mrTPoints[row.id] }}
          <span
            v-if="isCurrentlyMrT(row).value"
            class="tag is-info is-small mb-2 is-valign-middle has-text-weight-bold is-inline-flex"
            title="🕵️"
          >
            Mr. T
          </span>
        </div>
      </o-table-column>
      <o-table-column #default="{ row }" field="active" label="Aktiv" sortable>
        <span>
          <o-switch
            :model-value="row.active"
            @update:modelValue="(value) => setGroupActive(row.id, value)"
          ></o-switch>
        </span>
      </o-table-column>
    </o-table>
  </div>
</template>

<script setup>
import { storeToRefs } from 'pinia'
import { supabase } from '@/client'
import { useGroups } from '@/stores/groups'
import { computed } from 'vue'
import { useAbteilungen } from '@/stores/abteilungen'
import { useGroupScores } from '@/stores/groupScores'

const groupsStore = useGroups()
groupsStore.subscribe()
const { all: groups } = storeToRefs(groupsStore)

const abteilungenStore = useAbteilungen()
abteilungenStore.subscribe()
const { all: abteilungen } = storeToRefs(abteilungenStore)

const changeAbteilung = async (id, newAbteilungId) => {
  await supabase
    .from('groups')
    .update({ abteilung_id: newAbteilungId })
    .eq('id', id)
}
const setGroupActive = async (id, newActive) => {
  await supabase.from('groups').update({ active: newActive }).eq('id', id)
}

const groupScoresStore = useGroupScores()
groupScoresStore.subscribe()
const { balances, realEstatePoints, mrTPoints, interestRates, totals } =
  storeToRefs(groupScoresStore)

function rowClass(row) {
  if (!row.active) {
    return 'has-content-vcentered inactive-row'
  }
  return 'has-content-vcentered'
}

const sortByScore = (scoring) => (a, b, isAsc) => {
  if (!a || !(a.id in scoring)) return 1
  if (!b || !(b.id in scoring)) return -1
  return (isAsc ? 1 : -1) * (scoring[a.id] - scoring[b.id])
}

// TODO
const currentMrT = null

const isCurrentlyMrT = (group) => {
  return computed(() => group.id === currentMrT?.id)
}
</script>

<script>
export default {
  name: 'GroupManagement',
}
</script>
