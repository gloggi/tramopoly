<template>
  <div class="columns is-multiline">
    <tram-header>{{ group && group.name || '...' }}</tram-header>
    <div class="column is-full is-one-third-desktop is-offset-one-third-desktop">
      <group-detail v-if="groupId" :group-id="groupId" :all-groups="allGroups" :update-interval="5">
        <button v-if="groupIsActiveCaller" class="button is-link is-outlined is-danger is-pulled-left" @click="finishCall" style="margin-bottom: 20px;">⬅️ Tschau {{ loggedInOperator.activeCall.scoutName }} 👋</button>
        <button v-else class="button is-link is-outlined is-info is-pulled-left" @click="redirectToZentrale" style="margin-bottom: 20px;">⬅️ Zrugg zu dä Übärsicht</button>
      </group-detail>
      <div class="panel">
        <header class="panel-heading"><h4 class="title is-4">🚉 Station chaufä oder bsuächä</h4></header>
        <div class="panel-block">
          <div class="field has-addons" style="width: 100%">
            <p class="control has-icons-left is-expanded">
              <input class="input is-small" type="text" placeholder="Filtärä" v-model="searchterm" ref="searchfield" @input="scrollStationsToTop">
              <span class="icon is-small is-left">🔍</span>
            </p>
            <a class="button is-small" v-if="searchterm !== ''" @click="resetSearchTerm">❌</a>
          </div>
        </div>
        <div style="max-height: 400px; overflow-y: scroll" ref="stationList">
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
      </div>
      <div class="card" id="mr-t" v-if="group">
        <header class="card-content has-background-light">
          <b-tag v-if="group.isCurrentlyMrT" type="is-info" class="is-pulled-right is-medium">Aktuellä Mr. T!</b-tag>
          <h4 class="card-header-title title is-4">🕵️ Mr. T</h4>
          <h6 v-if="mrTSince" class="subtitle is-6">{{ mrTLocation }} ({{ mrTSince }})</h6>
        </header>
        <div class="card-content">
          <form v-on:submit.prevent="updateMrT">
            <b-field label="Tram / Bus / Zug"><b-input type="text" :placeholder="lastMrT.vehicle" v-model="mrT.vehicle"/></b-field>
            <b-field label="Letschti bekannti Station"><b-autocomplete :data="stationsFilteredByLastKnownStop" :placeholder="lastMrT.lastKnownStop" v-model="mrT.lastKnownStop" open-on-focus /></b-field>
            <b-field label="Richtig"><b-autocomplete :data="stationsFilteredByDirection" :placeholder="lastMrT.direction" v-model="mrT.direction" open-on-focus /></b-field>
            <b-field label="Beschriibig"><b-input type="textarea" :placeholder="lastMrT.description" v-model="mrT.description"/></b-field>
            <button v-if="group.isCurrentlyMrT" class="button is-link" type="submit">Mr T. aktualisiärä</button>
            <button v-else class="button is-link" type="submit">{{ group.name }} zum Mr T. machä!</button>
          </form>
        </div>
      </div>
      <slot name="message"></slot>
    </div>
  </div>
</template>

<script>
import {
  addJokerVisit,
  addMrTChange,
  addStationVisit,
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
import GroupDetail from '@/components/GroupDetail'
import BTag from 'buefy/src/components/tag/Tag'
import allStationsInZurich from '@/allStationsInZurich'
import BAutocomplete from 'buefy/src/components/autocomplete/Autocomplete'
import BInput from 'buefy/src/components/input/Input'
import { setPageTitle } from '@/router'
import { renderMrTSince } from '@/business'

export default {
  name: 'Aktion',
  components: { BInput, BAutocomplete, BTag, GroupDetail, BTableColumn, BTable, BField, TramHeader },
  props: {
    allGroups: { type: Array, required: true },
    stationOwners: { type: Map, required: true },
    mrTLocation: { type: String, required: true },
    now: { type: Date, required: true }
  },
  data () {
    return {
      loggedInOperator: null,
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
  methods: {
    canVisitStation (station) {
      return this.group && station.value <= this.group.saldo
    },
    ownsStation (station) {
      let owner = this.stationOwners.get(station.id)
      return owner && owner.id === this.groupId
    },
    hasVisitedJoker (joker) {
      return this.jokerVisits.some(visit => visit.group && visit.group.id === this.groupId && visit.station && visit.station.id === joker.id)
    },
    resetSearchTerm () {
      this.searchterm = ''
      this.$refs.searchfield.focus()
      this.scrollStationsToTop()
    },
    scrollStationsToTop () {
      this.$nextTick(() => {
        this.$refs.stationList.scrollTop = 0
      })
    },
    visitStation (station) {
      addStationVisit(this.groupId, station.id).then(() => {
        this.$emit('updateNow')
        if (this.stationOwners.get(station.id).id === this.groupId) {
          this.snackbar('🎉🙌 Perf! Ier händ d Station gchauft! Schtämplä nöd vergässä ️🎫‼️', 'Gschtämplät 👍🏼')
        } else {
          this.snackbar('😓😣 Ja nääi! Die Station ghört scho anärä andärä Gruppä... Iär händ müäsä Miäti zahle 📉🆘', 'Okei... 😢', 'is-danger')
        }
      })
    },
    visitJoker (joker) {
      addJokerVisit(this.groupId, joker.id).then(() => {
        this.$emit('updateNow')
        this.snackbar('🤑💰 Judihui! Ier händ Gäld übercho für diä Jokerstation! Schtämplä nöd vergässä ️🎫‼️', 'Gschtämplät 👍🏼')
      })
    },
    updateMrT () {
      addMrTChange(this.groupId, this.mrT).then(() => {
        this.$emit('updateNow')
        this.snackbar('👍🕵️ Mässi! Dä Mr. T isch aktualisiärt wordä. Lütäd in 10 Minutä widär aa. 🏃🕑', 'Bis bald ☎️📳')
      })
    },
    snackbar (message, button = 'OK', type = 'is-success') {
      this.$snackbar.open({ message, type, position: 'is-top', indefinite: true, actionText: button })
    },
    finishCall () {
      setActiveCall(this.loggedInOperator.id, null).then(this.redirectToZentrale)
    },
    redirectToZentrale () {
      this.$router.push({ name: 'zentrale' })
    },
    searchArrayFor (array, searchTerm, fieldExtractor = elem => elem) {
      let result = array.filter(elem => fieldExtractor(elem).toLocaleLowerCase().startsWith(searchTerm.toLocaleLowerCase().trim()))
      result = result.concat(array.filter(elem => result.indexOf(elem) < 0 && fieldExtractor(elem).toLocaleLowerCase().includes(' ' + searchTerm.toLocaleLowerCase().trim())))
      result = result.concat(array.filter(elem => result.indexOf(elem) < 0 && fieldExtractor(elem).toLocaleLowerCase().includes(searchTerm.toLocaleLowerCase().trim())))
      return result
    }
  },
  computed: {
    groupId () {
      return this.$route.params.group
    },
    group () {
      return this.allGroups.find(group => group.id === this.groupId)
    },
    combinedStations () {
      return this.stations.map(station => ({ id: station.id, ...station })).concat(this.jokers.map(joker => ({ joker: true, id: joker.id, ...joker }))).sort((a, b) => a.name.localeCompare(b.name))
    },
    filteredStations () {
      return this.searchArrayFor(this.combinedStations.map(station => ({ ...station, name: station.name + (station.joker ? ' (Joker)' : '') })), this.searchterm, station => station.name)
    },
    visitedStations () {
      return this.stationVisits.filter(visit => visit.group && visit.group.id === this.groupId).map(visit => visit.station)
    },
    lastMrT () {
      if (this.mrTChanges.length === 0) return this.mrT
      return this.mrTChanges[this.mrTChanges.length - 1]
    },
    mrTSince () {
      return renderMrTSince(this.mrTChanges, this.now)
    },
    groupIsActiveCaller () {
      return !!(this.loggedInOperator && this.loggedInOperator.activeCall && this.loggedInOperator.activeCall.group && this.loggedInOperator.activeCall.group.id === this.groupId)
    },
    stationsFilteredByLastKnownStop () {
      return this.searchArrayFor(this.allStationsInZurich, this.mrT.lastKnownStop)
    },
    stationsFilteredByDirection () {
      return this.searchArrayFor(this.allStationsInZurich, this.mrT.direction)
    }
  },
  watch: {
    group: function () {
      setPageTitle(this.group.name)
    }
  }
}
</script>
