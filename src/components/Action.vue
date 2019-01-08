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
        <div v-if="ownsStation(station)" :key="station.id" class="panel-block is-owned">
          <span class="panel-icon">✅</span>
          <span class="has-text-weight-bold">{{ station.name }}</span><span>{{ station.value }}.-</span>
        </div>
        <div v-else-if="visitedStations.map(visited => visited.id).includes(station.id)" :key="station.id" class="panel-block is-visited-before">
          <span class="panel-icon">❎</span>
          <span class="has-text-weight-bold">{{ station.name }}</span><span>{{ station.value }}.-</span>
        </div>
        <div v-else-if="!canVisitStation(station)" :key="station.id" class="panel-block is-strikethrough">
          <span class="panel-icon"></span>
          <span class="has-text-weight-bold">{{ station.name }}</span><span>{{ station.value }}.-</span>
        </div>
        <a v-else :key="station.id" class="panel-block" @click="visitStation(station)">
          <span class="panel-icon"></span>
          <span class="has-text-weight-bold">{{ station.name }}</span> <span>{{ station.value }}.-</span>
        </a>
      </template>
    </div>
  </div>
</template>

<script>
import { addStationVisit, groupsDB, requireOperator, settingsDB, stationsDB, stationVisitsDB } from '@/firebaseConfig'
import TramHeader from '@/components/TramHeader'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import { groupSaldo, stationOwners } from '@/business'

export default {
  name: 'Action',
  components: { BTableColumn, BTable, TramHeader },
  data () {
    return {
      group: { name: '' },
      stations: [],
      settings: null,
      stationVisits: [],
      searchterm: '',
      now: new Date(),
      saldoTimer: null
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
    this.updateNow()
  },
  methods: {
    updateNow () {
      clearInterval(this.saldoTimer)
      this.now = new Date()
      this.saldoTimer = setInterval(this.updateNow, 1000 * 5)
    },
    canVisitStation (station) {
      return station.value <= this.saldo
    },
    ownsStation (station) {
      return this.stationOwners.get(station.id) === this.group.id
    },
    resetSearchTerm () {
      this.searchterm = ''
    },
    visitStation (station) {
      addStationVisit(this.group.id, station.id).then(() => this.updateNow())
    }
  },
  computed: {
    saldo () {
      return groupSaldo(this.group.id, this.settings, this.stationVisits, this.now)
    },
    filteredStations () {
      return this.stations.filter(station => station.name && station.name.toLocaleLowerCase().includes(this.searchterm.toLocaleLowerCase()))
    },
    stationOwners () {
      return stationOwners(this.stationVisits)
    },
    visitedStations () {
      return this.stationVisits.filter(visit => visit.group.id === this.group.id).map(visit => visit.station)
    }
  }
}
</script>
