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
        <span>
          <span class="has-text-weight-bold">{{ row.name }}</span>

          <span
            v-if="isCurrentlyMrT(row).value"
            class="tag is-info is-pulled-right is-small mb-2 is-valign-text-top"
            title="🕵️"
          >
            Mr. T
          </span>
        </span>
      </o-table-column>
      <o-table-column #default="{ row }" field="active" label="Aktiv" sortable>
        <span>
          <o-switch
            :model-value="row.active"
            @update:modelValue="(value) => setGroupActive(row.id, value)"
          ></o-switch>
        </span>
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
        field="total"
        label="Total"
        sortable
        numeric
        :custom-sort="
          (a, b, isAsc) => (isAsc ? 1 : -1) * (totals[a.id] - totals[b.id])
        "
      >
        <span>{{ totals[row.id] }}</span>
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
const { totals } = storeToRefs(groupScoresStore)

function rowClass(row) {
  if (!row.active) {
    return 'has-content-vcentered inactive-row'
  }
  return 'has-content-vcentered'
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
