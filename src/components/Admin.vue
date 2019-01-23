<template>
  <div class="columns is-multiline">
    <tram-header>Admin</tram-header>
    <div class="column is-full has-text-centered">
      <div v-if="loggedInOperatorBusy" class="card">
        <div class="card-content">
          <header class="card-header-title is-centered">Aktivä Aruäf: {{ loggedInAdmin.activeCall.scoutName }}</header>
          <button @click="clearActiveCall" class="button is-danger">Aktivä Aruäf beändä</button>
        </div>
      </div>
      <div class="card has-text-left">
        <header class="card-header has-background-light"><span class="card-header-title title is-4">⚙️ Iistelligä</span></header>
        <div class="card-content">
          <div class="columns">
            <div class="column">
              <b-field grouped group-multiline>
                <b-field label="Start"><b-input readonly :value="gameStart" expanded /></b-field>
                <b-field label="Ändi"><b-input readonly :value="gameEnd" expanded /></b-field>
              </b-field>
              <p class="control"><button @click="setStartTimeToNow" class="level-left button is-danger" expanded>Spiel startä (3ähalb stund)</button></p>
            </div>
            <div class="column" v-if="message">
              <header class="title is-4">Nachricht a alli</header>
              <form @submit.prevent="setMessage">
                <b-field grouped group-multiline>
                  <b-field><b-select name="type" v-model="selectedMessageType">
                    <option value="is-info">blau</option>
                    <option value="is-success">grüän</option>
                    <option value="is-warning">gääl</option>
                    <option value="is-danger">rot</option>
                    <option value="">schwarz</option>
                  </b-select></b-field>
                  <b-field><b-input type="text" :value="message.title" name="title" placeholder="Titäl"></b-input></b-field>
                  <b-field><button type="submit" class="button is-primary">Speichärä</button></b-field>
                </b-field>
                <b-field><b-input type="textarea" :value="message.message" name="message"></b-input></b-field>
              </form>
            </div>
          </div>
          <div class="columns"><div class="column is-full is-one-third-desktop is-offset-one-third-desktop"><slot></slot></div></div>
        </div>
      </div>
      <div class="card" v-if="abteilungenReady">
        <header class="card-header has-background-light"><span class="card-header-title title is-4">⚜️ Abteiligä</span></header>
        <b-table class="has-content-vcentered" :data="abteilungen" striped hoverable :row-class="hasContentVcentered" default-sort="totalPoints" default-sort-direction="desc">
          <template slot-scope="props">
            <b-table-column field="name" label="Abteilig" sortable>
              <span v-if="props.row.id" class="icon is-medium"><img :title="props.row.name" style="opacity: 0.7" :src="require('../../static/' + props.row.id + '.svg')"/></span>
              <span class="has-text-weight-bold">{{ props.row.name }}</span>
            </b-table-column>
            <b-table-column field="saldo" label="Guäthabä" sortable>{{ props.row.saldo }}</b-table-column>
            <b-table-column field="realEstatePoints" label="Immobiliä" sortable>{{ props.row.realEstatePoints }}</b-table-column>
            <b-table-column field="mrTPoints" label="Mr. T" sortable>{{ props.row.mrTPoints }}</b-table-column>
            <b-table-column field="totalPoints" label="Total" sortable><span class="has-text-weight-bold">{{ props.row.totalPoints }}</span></b-table-column>
            <b-table-column field="operator.scoutName" label="Telefonischt">
              <b-select @change="changeOperator(props.row.id, $event.target.value)">
                  <option value=""></option>
                  <option v-for="option in operators" :value="option.id" :key="option.id" :selected="props.row.operator.id === option.id">{{ option.scoutName }}</option>
              </b-select>
            </b-table-column>
          </template>
        </b-table>
      </div>
      <div class="card" v-if="users.length">
        <header class="card-header has-background-light"><span class="card-header-title title is-4">🧒 Benutzär</span></header>
        <b-table class="has-content-vcentered" :data="users" striped hoverable :row-class="hasContentVcentered">
          <template slot-scope="props">
            <b-table-column field="scoutName" label="Namä" sortable><span class="has-text-weight-bold">{{ props.row.scoutName }}</span></b-table-column>
            <b-table-column field="phone" label="Telefon" sortable>{{ props.row.phone }}</b-table-column>
            <b-table-column field="group.abteilung.name" label="Abteilig" sortable>
              <span v-if="props.row.group.abteilung">
                <span v-if="props.row.group.abteilung.id" class="icon is-medium"><img :title="props.row.group.abteilung.name" style="opacity: 0.7" :src="require('../../static/' + props.row.group.abteilung.id + '.svg')"/></span>
                <span>{{ props.row.group.abteilung.name }}</span>
              </span>
            </b-table-column>
            <b-table-column field="group.name" label="Gruppä" sortable>{{ props.row.group.name }}</b-table-column>
            <b-table-column field="role" label="Rollä" sortable>{{ props.row.role }}</b-table-column>
          </template>
        </b-table>
      </div>
      <div class="card" v-if="allEventsCombined.length">
        <header class="card-header has-background-light"><span class="card-header-title title is-4">🚉 Stationä, 🃏 Joker & 🕵️ Mr. T</span></header>
        <b-table class="has-content-vcentered" :data="allEventsCombined" striped hoverable :row-class="hasContentVcentered">
          <template slot-scope="props">
            <b-table-column field="abteilung.name" label="Ziit">
              {{ props.row.time.toDate().toLocaleTimeString() }}
            </b-table-column>
            <b-table-column field="name" label="Gruppä">
              <span v-if="props.row.group && props.row.group.abteilung && props.row.group.abteilung.id" class="icon is-medium"><img :title="props.row.group.abteilung.name" style="opacity: 0.7" :src="require('../../static/' + props.row.group.abteilung.id + '.svg')"/></span>
              <span>{{ props.row.group.name }}</span>
            </b-table-column>
            <b-table-column field="type" label="Typ">
              <span v-if="props.row.type === 'joker'" :key="props.row.id">
                <span class="icon">🃏</span>
                <span>{{ props.row.station.name }} (Joker)</span>
              </span>
              <span v-else-if="props.row.type === 'station'" :key="props.row.id">
                <span class="icon">🚉</span>
                <span>{{ props.row.station.name }}</span>
              </span>
              <span v-else-if="props.row.type === 'mrT'" :key="props.row.id">
                <span class="icon">🕵️</span>
                <span>Mr. T '{{ props.row.vehicle }}' in '{{ props.row.lastKnownStop}}' richtung '{{ props.row.direction }}'; '{{ props.row.description }}'</span>
              </span>
            </b-table-column>
          </template>
        </b-table>
      </div>
    </div>
  </div>
</template>

<script>
import {
  changeGroupOperator,
  jokerVisitsDB,
  mrTChangesDB,
  requireOperator,
  setActiveCall,
  setGameEndTime, setGlobalMessage,
  settingsDB,
  stationVisitsDB,
  usersDB
} from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import TramHeader from '@/components/TramHeader'
import Placeholder from '@/components/Placeholder'
import BInput from 'buefy/src/components/input/Input'
import BSelect from 'buefy/src/components/select/Select'
import BField from 'buefy/src/components/field/Field'

export default {
  name: 'Admin',
  components: { BField, BSelect, BInput, Placeholder, BTable, BTableColumn, TramHeader },
  props: {
    allGroups: { type: Array, required: true }
  },
  data () {
    return {
      loggedInAdmin: null,
      stationVisits: [],
      jokerVisits: [],
      mrTChanges: [],
      settings: null,
      users: [],
      selectedMessageType: 'is-info'
    }
  },
  firestore: {
    stationVisits: stationVisitsDB,
    jokerVisits: jokerVisitsDB,
    mrTChanges: mrTChangesDB,
    settings: settingsDB,
    users: usersDB
  },
  beforeRouteEnter (to, from, next) {
    requireOperator(to, from, next)
  },
  computed: {
    loggedInOperatorBusy () {
      return !!(this.loggedInAdmin && this.loggedInAdmin.activeCall)
    },
    gameDuration () {
      return 4.5 * 60 * 60 * 1000
    },
    gameStart () {
      return this.settings && new Date(this.settings.gameEnd.toDate() - this.gameDuration).toLocaleTimeString()
    },
    gameEnd () {
      return this.settings && this.settings.gameEnd.toDate().toLocaleTimeString()
    },
    allEventsCombined () {
      return [].concat(
        this.stationVisits.map(visit => ({ ...visit, id: visit.id, type: 'station' })),
        this.jokerVisits.map(visit => ({ ...visit, id: visit.id, type: 'joker' })),
        this.mrTChanges.map(change => ({ ...change, id: change.id, type: 'mrT' }))
      ).sort((a, b) => b.time.toDate() - a.time.toDate())
    },
    abteilungen () {
      let map = new Map()
      this.allGroups.forEach(group => {
        let id = group.abteilung.id
        if (!map.has(id)) {
          let operator = { name: 'Unbekannt', id: '' }
          if (group.abteilung && group.abteilung.operator && group.abteilung.operator.id) {
            operator = { name: group.abteilung.operator.scoutName, id: group.abteilung.operator.id }
          }
          map.set(id, { id, name: group.abteilung.name, operator, saldo: 0, realEstatePoints: 0, mrTPoints: 0, totalPoints: 0, numGroups: 0 })
        }
        let abteilung = map.get(id)
        abteilung.saldo += group.saldo
        abteilung.realEstatePoints += group.realEstatePoints
        abteilung.mrTPoints += group.mrTPoints
        abteilung.totalPoints += group.totalPoints
        abteilung.numGroups += 1
      })
      map.forEach(abteilung => {
        abteilung.saldo = Math.round(abteilung.saldo / abteilung.numGroups)
        abteilung.realEstatePoints = Math.round(abteilung.realEstatePoints / abteilung.numGroups)
        abteilung.mrTPoints = Math.round(abteilung.mrTPoints / abteilung.numGroups)
        abteilung.totalPoints = Math.round(abteilung.totalPoints / abteilung.numGroups)
      })
      return Array.from(map.values())
    },
    abteilungenReady () {
      return this.abteilungen.length > 0
    },
    operators () {
      if (!this.users) return []
      return this.users.filter(user => user.role === 'operator' || user.role === 'admin')
    },
    message () {
      return this.settings && this.settings.message
    }
  },
  methods: {
    clearActiveCall () {
      setActiveCall(this.loggedInAdmin.id, null)
    },
    selectGroup (group) {
      this.$router.push({ name: 'action', params: { group: group.id } })
    },
    markIfCallingGroup (group) {
      return (this.loggedInAdmin &&
        this.loggedInAdmin.activeCall &&
        this.loggedInAdmin.activeCall.group &&
        this.loggedInAdmin.activeCall.group.id === group.id) ? 'is-active-call is-clickable has-content-vcentered' : 'is-clickable has-content-vcentered'
    },
    setStartTimeToNow () {
      setGameEndTime(new Date(new Date().getTime() + this.gameDuration))
    },
    hasContentVcentered () {
      return 'has-content-vcentered'
    },
    changeOperator (abteilungId, operatorId) {
      changeGroupOperator(abteilungId, operatorId)
    },
    setMessage (submitEvent) {
      setGlobalMessage(submitEvent.target.elements.type.value, submitEvent.target.elements.title.value, submitEvent.target.elements.message.value)
    }
  }
}
</script>
