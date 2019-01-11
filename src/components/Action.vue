<template>
  <div class="columns is-multiline">
    <tram-header>Gruppä {{ group.name }}</tram-header>
    <group-detail ref="groupDetails" :group-id="group && group.id" :update-interval="5">
      <button v-if="groupIsActiveCaller" class="button is-link is-outlined is-danger is-pulled-right" @click="finishCall">⬅️ Färtig telefoniärt</button>
      <button v-else class="button is-link is-outlined is-info is-pulled-right" @click="redirectToZentrale">⬅️ Zrugg zu dä Übärsicht</button>
    </group-detail>
    <div class="panel column is-full is-one-third-desktop is-offset-one-third-desktop">
      <header class="panel-heading"><h4 class="title is-4">Station chaufä oder bsuächä</h4></header>
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
        <div v-if="station.joker && hasVisitedJoker(station)" :key="'joker-' + station.name" class="panel-block is-owned">
          <span class="panel-icon">🃏</span>
          <span class="has-text-weight-bold">{{ station.name }} (Joker)</span><span>{{ station.value }}.-</span>
        </div>
        <a v-else-if="station.joker" :key="'joker-' + station.name" class="panel-block" @click="visitJoker(station)">
          <span class="panel-icon"></span>
          <span class="has-text-weight-bold">{{ station.name }} (Joker)</span><span>{{ station.value }}.-</span>
        </a>
        <div v-else-if="ownsStation(station)" :key="station.id" class="panel-block is-owned">
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
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      <b-tag v-if="groupIsCurrentlyMrT" type="is-info" class="is-pulled-right is-medium">Miär sind Mr. T!</b-tag>
      <h4 class="title is-4">Mr. T</h4>
      <form v-on:submit.prevent="updateMrT">
        <b-field label="Tram / Zug"><b-input type="text" :placeholder="lastMrT.vehicle" v-model="mrT.vehicle"/></b-field>
        <b-field label="Letschti bekannti Station"><b-autocomplete :data="allStationsInZurich" :placeholder="lastMrT.lastKnownStop" v-model="mrT.lastKnownStop" open-on-focus /></b-field>
        <b-field label="Richtig"><b-autocomplete :data="allStationsInZurich" :placeholder="lastMrT.direction" v-model="mrT.direction" open-on-focus /></b-field>
        <b-field label="Beschriibig"><b-input type="textarea" :placeholder="lastMrT.description" v-model="mrT.description"/></b-field>
        <button class="button is-link" type="submit">Mr T. aktualisiärä</button>
      </form>
    </div>
  </div>
</template>

<script>
import {
  addJokerVisit,
  addMrTChange,
  addStationVisit,
  groupsDB,
  jokersDB,
  jokerVisitsDB,
  mrTChangesDB,
  requireOperator,
  setActiveCall,
  stationsDB,
  stationVisitsDB
} from '@/firebaseConfig'
import TramHeader from '@/components/TramHeader'
import BField from 'buefy/src/components/field/Field'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import { stationOwners } from '@/business'
import GroupDetail from '@/components/GroupDetail'
import BTag from 'buefy/src/components/tag/Tag'
import allStationsInZurich from '@/allStationsInZurich'
import BAutocomplete from 'buefy/src/components/autocomplete/Autocomplete'
import BInput from 'buefy/src/components/input/Input'

export default {
  name: 'Action',
  components: { BInput, BAutocomplete, BTag, GroupDetail, BTableColumn, BTable, BField, TramHeader },
  data () {
    return {
      loggedInOperator: null,
      group: { name: '' },
      stations: [],
      jokers: [],
      stationVisits: [],
      jokerVisits: [],
      mrTChanges: [],
      searchterm: '',
      mrT: { vehicle: '', direction: '', lastKnownStop: '', description: '', group: {} },
      allStationsInZurich: allStationsInZurich
    }
  },
  firestore: {
    stations: stationsDB,
    jokers: jokersDB,
    stationVisits: stationVisitsDB,
    jokerVisits: jokerVisitsDB,
    mrTChanges: mrTChangesDB
  },
  beforeRouteEnter (to, from, next) {
    requireOperator(to, from, next)
  },
  created () {
    this.$bind('group', groupsDB.doc(this.$route.params.group))
  },
  methods: {
    canVisitStation (station) {
      return station.value <= this.$refs.groupDetails.saldo
    },
    ownsStation (station) {
      return this.stationOwners.get(station.id) === this.group.id
    },
    hasVisitedJoker (joker) {
      return this.jokerVisits.some(visit => visit.group.id === this.group.id && visit.station.id === joker.id)
    },
    resetSearchTerm () {
      this.searchterm = ''
    },
    visitStation (station) {
      addStationVisit(this.group.id, station.id).then(() => {
        if (stationOwners(this.stationVisits, this.now).get(station.id) === this.group.id) {
          this.snackbar('🎉🙌 Perf! Ier händ d Station gchauft! Schtämplä nöd vergässä ️🎫‼️', 'Gschtämplät 👍🏼')
        } else {
          this.snackbar('😓😣 Ja nääi! Die Station ghört scho anärä andärä Gruppä... Iär händ müäsä Miäti zahle 📉🆘', 'Okei... 😢', 'is-danger')
        }
      })
    },
    visitJoker (joker) {
      addJokerVisit(this.group.id, joker.id).then(() => this.snackbar('🤑💰 Judihui! Ier händ Gäld übercho für diä Jokerstation! Schtämplä nöd vergässä ️🎫‼️', 'Gschtämplät 👍🏼'))
    },
    updateMrT () {
      addMrTChange(this.group.id, this.mrT)
    },
    snackbar (message, button = 'OK', type = 'is-success') {
      this.$snackbar.open({ message, type, position: 'is-top', indefinite: true, actionText: button })
    },
    finishCall () {
      setActiveCall(this.loggedInOperator.id, null).then(this.redirectToZentrale)
    },
    redirectToZentrale () {
      this.$router.push({ name: 'zentrale' })
    }
  },
  computed: {
    combinedStations () {
      return this.stations.map(station => ({ id: station.id, ...station })).concat(this.jokers.map(joker => ({ joker: true, id: joker.id, ...joker }))).sort((a, b) => a.name.localeCompare(b.name))
    },
    filteredStations () {
      return this.combinedStations.filter(station => station.name && (station.name + (station.joker ? ' (Joker)' : '')).toLocaleLowerCase().includes(this.searchterm.toLocaleLowerCase()))
    },
    stationOwners () {
      return stationOwners(this.stationVisits)
    },
    visitedStations () {
      return this.stationVisits.filter(visit => visit.group.id === this.group.id).map(visit => visit.station)
    },
    lastMrT () {
      if (this.mrTChanges.length === 0) return this.mrT
      return this.mrTChanges[this.mrTChanges.length - 1]
    },
    groupIsCurrentlyMrT () {
      return this.group.id && this.lastMrT.group.id === this.group.id
    },
    groupIsActiveCaller () {
      return !!(this.group.id && this.loggedInOperator && this.loggedInOperator.activeCall && this.loggedInOperator.activeCall.group && this.loggedInOperator.activeCall.group.id === this.group.id)
    }
  }
}
</script>
