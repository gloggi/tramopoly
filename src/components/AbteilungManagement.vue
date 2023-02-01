<template>
  <div class="card" v-if="!loading">
    <header class="card-header has-background-light">
      <span class="card-header-title title is-4">⚜ Abteiligä </span>
      <abteilung-edit-modal>➕ Neui Abtäilig</abteilung-edit-modal>
    </header>
    <o-table
      table-class="has-content-vcentered is-table-layout-fixed"
      :data="abteilungen"
      striped
      hoverable
      :row-class="rowClass"
      default-sort="name"
      style="table-layout: fixed"
    >
      <o-table-column #default="{ row }" field="name" label="Abteilig" sortable>
        <span v-if="row.id" class="icon is-medium">
          <img
            :title="row.name"
            :alt="row.name"
            style="opacity: 0.7"
            :src="row.logoUrl"
          />
        </span>
        <span class="has-text-weight-bold">{{ row.name }}</span>
      </o-table-column>
      <o-table-column
        #default="{ row }"
        field="totalPoints"
        label="Total"
        sortable
        numeric
        :custom-sort="sortByScore(totals)"
      >
        <span class="has-text-weight-bold">
          {{ totals[row.id] }}
        </span>
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
      <o-table-column
        #default="{ row }"
        field="operator.scoutName"
        label="Telefonischt"
      >
        <span>
          <o-select
            @update:modelValue="(value) => changeOperator(row.id, value)"
            :model-value="row.operatorId"
          >
            <option value=""></option>
            <option
              v-for="option in operators"
              :value="option.id"
              :key="option.id"
            >
              {{ option.scoutName }}
            </option>
          </o-select>
        </span>
      </o-table-column>
      <o-table-column #default="{ row }" field="active" label="Aktiv" sortable>
        <span>
          <o-switch
            :model-value="row.active"
            @update:modelValue="(value) => setAbteilungActive(row.id, value)"
          ></o-switch>
          <abteilung-edit-modal :abteilung="row">
            <o-icon icon="edit"></o-icon>
          </abteilung-edit-modal>
        </span>
      </o-table-column>
    </o-table>
  </div>
</template>

<script setup>
import { storeToRefs } from 'pinia'
import { supabase } from '@/client'
import { useAbteilungen } from '@/stores/abteilungen'
import { useProfiles } from '@/stores/profiles'
import { useAbteilungScores } from '@/composables/abteilungScores'
import AbteilungEditModal from '@/components/AbteilungEditModal'
import { computed } from 'vue'
import { useCurrentMrT } from '@/composables/useCurrentMrT'

const abteilungenStore = useAbteilungen()
abteilungenStore.subscribe()
const { all: abteilungen, loading } = storeToRefs(abteilungenStore)

const operatorsStore = useProfiles({
  filter: { in: ['role', ['operator', 'admin']] },
})
operatorsStore.subscribe()
const { all: operators } = storeToRefs(operatorsStore)

const changeOperator = async (id, newOperatorId) => {
  await supabase
    .from('abteilungen')
    .update({ operator_id: newOperatorId || null })
    .eq('id', id)
}
const setAbteilungActive = async (id, newActive) => {
  await supabase.from('abteilungen').update({ active: newActive }).eq('id', id)
}

const {
  averageBalancesByAbteilung: balances,
  averageInterestRatesByAbteilung: interestRates,
  averageRealEstatePointsByAbteilung: realEstatePoints,
  averageMrTPointsByAbteilung: mrTPoints,
  averageTotalsByAbteilung: totals,
} = useAbteilungScores()

const sortByScore = (scoring) => (a, b, isAsc) => {
  if (!a || !(a.id in scoring)) return 1
  if (!b || !(b.id in scoring)) return -1
  return (isAsc ? 1 : -1) * (scoring[a.id] - scoring[b.id])
}

function rowClass(row) {
  if (!row.active) {
    return 'has-content-vcentered inactive-row'
  }
  return 'has-content-vcentered'
}

const { currentMrT } = useCurrentMrT()
const isCurrentlyMrT = (abteilung) => {
  return computed(() => abteilung.id === currentMrT.value?.group?.abteilungId)
}
</script>

<script>
export default {
  name: 'AbteilungManagement',
}
</script>
