<template>
  <div class="columns is-multiline">
    <tram-header>Gruppä {{ group.name }}</tram-header>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      Saldo: {{ saldo(group.id) }}.-
    </div>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      <header class="title is-5">Station chaufä oder bsuächä</header>
      <b-table :data="stations" striped hoverable :row-class="stationListRowClass">
        <template slot-scope="props">
          <b-table-column field="name" label="Station">
            {{ props.row.name }}
          </b-table-column>
          <b-table-column field="value" label="Wert">
            {{ props.row.value }}.-
          </b-table-column>
        </template>
      </b-table>
    </div>
  </div>
</template>

<script>
import { groupsDB, requireOperator, settingsDB, stationsDB } from '@/firebaseConfig'
import TramHeader from '@/components/TramHeader'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import { groupSaldo } from '@/business'

export default {
  name: 'Action',
  components: { BTableColumn, BTable, TramHeader },
  data () {
    return {
      group: { name: '' },
      stations: [],
      settings: null
    }
  },
  firestore: {
    stations: stationsDB,
    settings: settingsDB
  },
  beforeRouteEnter (to, from, next) {
    requireOperator(to, from, next)
  },
  created () {
    this.$bind('group', groupsDB.doc(this.$route.params.group))
  },
  methods: {
    saldo (groupId) {
      return groupSaldo(groupId, this.settings)
    },
    stationListRowClass (row) {
      return row.value > this.saldo(this.group.id) ? 'is-strikethrough' : ''
    }
  }
}
</script>
