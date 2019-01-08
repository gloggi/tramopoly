<template>
  <div class="columns is-multiline">
    <tram-header>Gruppä {{ group.name }}</tram-header>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      Saldo: {{ saldo }}.-
    </div>
    <div class="panel column is-full is-one-third-desktop is-offset-one-third-desktop">
      <header class="panel-heading">Station chaufä oder bsuächä</header>
      <div class="panel-block">
        <div class="field has-addons" style="width: 100%">
          <p class="control has-icons-left is-expanded">
            <input class="input is-small" type="text" placeholder="Filtärä" v-model="searchterm">
            <span class="icon is-small is-left">🔍</span>
          </p>
          <a class="button is-small" v-if="searchterm !== ''" @click="resetSearchTerm">❌</a>
        </div>
      </div>
      <template v-for="station in filteredStations">
        <a v-if="canVisitStation(station)" :key="station.id" class="panel-block" @click="visitStation(station)">{{ station.name }} {{ station.value }}.-</a>
        <a v-else :key="station.id" class="panel-block is-strikethrough">{{ station.name }} {{ station.value }}.-</a>
      </template>
    </div>
  </div>
</template>

<script>
import { addStationVisit, groupsDB, requireOperator, settingsDB, stationsDB, stationVisitsDB } from '@/firebaseConfig'
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
      settings: null,
      stationVisits: [],
      searchterm: ''
    }
  },
  firestore: {
    stations: stationsDB,
    settings: settingsDB,
    stationVisits: stationVisitsDB
  },
  beforeRouteEnter (to, from, next) {
    requireOperator(to, from, next)
  },
  created () {
    this.$bind('group', groupsDB.doc(this.$route.params.group))
  },
  methods: {
    canVisitStation (station) {
      return station.value <= this.saldo
    },
    resetSearchTerm () {
      this.searchterm = ''
    },
    visitStation (station) {
      addStationVisit(this.group.id, station.id)
    }
  },
  computed: {
    saldo () {
      return groupSaldo(this.group.id, this.settings, this.stationVisits)
    },
    filteredStations () {
      return this.stations.filter(station => station.name && station.name.toLocaleLowerCase().includes(this.searchterm.toLocaleLowerCase()))
    }
  }
}
</script>
