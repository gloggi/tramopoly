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
              <b-field><p class="control"><button @click="setStartTimeToNow" class="button is-info is-outlined">Spiel startä (4 ¾ stund)</button></p></b-field>
              <hr/>
              <b-field :label="checkpointLabel">
                <b-field>
                  <b-input v-model="checkpointTime" />
                  <p class="control"><button @click="createCheckpointToday" class="button is-info is-outlined">Checkpoint erstellä</button></p>
                </b-field>
              </b-field>
              <hr/>
              <b-field label="Regischtriärig für Zentralä">
                <b-switch type="is-danger" :value="operatorGroupActive" @input="value => setOperatorGroupAvailable(value)">
                  <span v-if="operatorGroupActive" class="has-text-weight-bold">Aktiviert</span>
                  <span v-else>Deaktiviert</span>
                </b-switch>
              </b-field>
            </div>
            <div class="column">
              <h5 class="title is-6">{{ minutesSinceLastActiveMrTChange }}</h5>
              <b-field grouped>
                <p class="control" v-if="mrTChanges && mrTChanges.length && !mrTShouldCallOperator">
                  <button class="button is-link is-warning" @click="() => promptMrT(currentMrT)">Gruppä zum Aruäf uffordärä</button>
                </p>
                <p class="control" v-if="currentMrTActive">
                  <button class="button is-link is-danger" @click="confiscateMrT">Mr T. beschlagnahmä</button>
                </p>
                <p class="control" v-else>
                  <button class="button is-link is-warning is-outlined" @click="releaseMrT">Mr T. hät sich gmäldät</button>
                </p>
              </b-field>
              <template v-if="message">
                <hr/>
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
                    <b-field><button type="submit" :class="'button ' + selectedMessageType">Speichärä</button></b-field>
                  </b-field>
                  <b-field><b-input type="textarea" :value="message.message" name="message"></b-input></b-field>
                </form>
              </template>
            </div>
          </div>
          <div class="columns"><div class="column is-full is-one-third-desktop is-offset-one-third-desktop"><slot name="message"></slot></div></div>
        </div>
      </div>
      <div class="card" v-if="abteilungenReady">
        <header class="card-header has-background-light"><span class="card-header-title title is-4"><span class="icon is-medium" style="margin-right: 0.5em"><img style="opacity: 0.7" :src="'/gloggi.svg'"/></span>Abteiligä</span></header>
        <b-table class="has-content-vcentered" :data="abteilungen" striped hoverable :row-class="hasContentVcentered" default-sort="totalPoints" default-sort-direction="desc">
          <template slot-scope="props">
            <b-table-column field="name" label="Abteilig" sortable>
              <span v-if="props.row.id" class="icon is-medium"><img :title="props.row.name" style="opacity: 0.7" :src="'/' + props.row.id + '.svg'"/></span>
              <span class="has-text-weight-bold">{{ props.row.name }}</span>
            </b-table-column>
            <b-table-column field="saldo" label="Guäthabä" sortable>{{ props.row.saldo }}</b-table-column>
            <b-table-column field="realEstatePoints" label="Immobiliä" sortable>{{ props.row.realEstatePoints }}</b-table-column>
            <b-table-column field="mrTPoints" label="Mr. T" sortable>{{ props.row.mrTPoints }}</b-table-column>
            <b-table-column field="totalPoints" label="Total" sortable><span class="has-text-weight-bold">{{ props.row.totalPoints }}</span></b-table-column>
            <b-table-column field="operator.scoutName" label="Telefonischt">
              <span>
                <b-select @input="value => changeOperator(props.row.id, value)" :value="props.row.operator.id">
                    <option value=""></option>
                    <option v-for="option in operators" :value="option.id" :key="option.id">{{ option.scoutName }}</option>
                </b-select>
              </span>
            </b-table-column>
          </template>
        </b-table>
      </div>
      <div class="card" v-if="users.length">
        <header class="card-header has-background-light"><span class="card-header-title title is-4">🧒 Benutzär</span></header>
        <b-table class="has-content-vcentered" :data="usersWithMrTFlag" striped hoverable :row-class="hasContentVcentered">
          <template slot-scope="props">
            <b-table-column field="scoutName" label="Namä" sortable><span><span class="has-text-weight-bold">{{ props.row.scoutName }}</span><b-tag v-if="props.row.isCurrentlyMrT" type="is-info" class="is-small is-pulled-right" title="🕵️">Mr. T</b-tag></span></b-table-column>
            <b-table-column field="phone" label="Telefon" sortable>{{ props.row.phone }}</b-table-column>
            <b-table-column field="group.abteilung.name" label="Abteilig" sortable>
              <span v-if="props.row.group && props.row.group.abteilung">
                <span v-if="props.row.group.abteilung.id" class="icon is-medium"><img :title="props.row.group.abteilung.name" style="opacity: 0.7" :src="'/' + props.row.group.abteilung.id + '.svg'"/></span>
                <span>{{ props.row.group.abteilung.name }}</span>
              </span>
            </b-table-column>
            <b-table-column field="group.name" label="Gruppä" sortable><span v-if="props.row.group">{{ props.row.group.name }}</span></b-table-column>
            <b-table-column field="role" label="Rollä" sortable>
              <span>
                <b-select @input="value => changeRole(props.row.id, value)" :value="props.row.role">
                  <option value="">Spielär</option>
                  <option value="operator">Zentralä</option>
                  <option value="admin">Admin</option>
                </b-select>
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
  addMrTChange,
  changeGroupOperator,
  changeUserRole,
  createCheckpoint,
  mrTChangesDB,
  requireOperator,
  setActiveCall,
  setGameEndTime,
  setGlobalMessage,
  setMrTShouldCallOperator,
  setOperatorGroupAvailable,
  settingsDB,
  usersDB
} from '../firebaseConfig'
import TramHeader from '../components/TramHeader'
import { renderTime, timeSinceLastActiveMrTChange } from '../business'

export default {
  name: 'Admin',
  components: { TramHeader },
  props: {
    allGroups: { type: Array, required: true },
    checkpoint: {},
    now: { type: Date, required: true }
  },
  data () {
    return {
      loggedInAdmin: null,
      mrTChanges: [],
      settings: null,
      users: [],
      selectedMessageType: 'is-info',
      eventSorter: (a, b) => b.time.toDate() - a.time.toDate(),
      checkpointTime: renderTime(-30)
    }
  },
  firestore: {
    mrTChanges: mrTChangesDB(),
    settings: settingsDB(),
    users: usersDB()
  },
  beforeRouteEnter (to, from, next) {
    requireOperator(to, from, next)
  },
  computed: {
    loggedInOperatorBusy () {
      return !!(this.loggedInAdmin && this.loggedInAdmin.activeCall)
    },
    gameDuration () {
      return 4.75 * 60 * 60 * 1000
    },
    gameStart () {
      return this.settings && new Date(this.settings.gameEnd.toDate() - this.gameDuration).toLocaleTimeString('de-CH')
    },
    gameEnd () {
      return this.settings && this.settings.gameEnd.toDate().toLocaleTimeString('de-CH')
    },
    abteilungen () {
      const map = new Map()
      this.allGroups.forEach(group => {
        const id = group.abteilung.id
        if (!map.has(id)) {
          let operator = { name: 'Unbekannt', id: '' }
          if (group.abteilung && group.abteilung.operator && group.abteilung.operator.id) {
            operator = { name: group.abteilung.operator.scoutName, id: group.abteilung.operator.id }
          }
          map.set(id, { id, name: group.abteilung.name, operator, saldo: 0, realEstatePoints: 0, mrTPoints: 0, totalPoints: 0, numGroups: 0 })
        }
        const abteilung = map.get(id)
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
    },
    mrTGroupId () {
      const found = this.allGroups.find(group => group.isCurrentlyMrT)
      return found && found.id
    },
    usersWithMrTFlag () {
      return this.users.map(user => ({ ...user, id: user.id, isCurrentlyMrT: user.group.id === this.mrTGroupId }))
    },
    operatorGroupActive () {
      return this.allGroups.some(group => group.id === 'zentrale')
    },
    currentMrT () {
      return [...this.mrTChanges].sort((a, b) => a.time.toDate() - b.time.toDate())[this.mrTChanges.length - 1] || {}
    },
    currentMrTActive () {
      return this.currentMrT.active !== false
    },
    mrTShouldCallOperator () {
      return this.currentMrT.shouldCallOperator
    },
    minutesSinceLastActiveMrTChange () {
      return timeSinceLastActiveMrTChange(this.checkpoint, this.mrTChanges, this.now)
    },
    checkpointLabel () {
      if (!this.checkpoint) return 'Bishär käin Checkpoint erstellt.'
      const latest = this.checkpoint.time.toDate().toLocaleTimeString('de-CH')
      const checkmark = (this.checkpointTime === latest) ? ' ✅' : ''
      return 'Letschtä Checkpoint: ' + latest + checkmark
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
    changeRole (userId, role) {
      changeUserRole(userId, role)
    },
    setMessage (submitEvent) {
      setGlobalMessage(submitEvent.target.elements.type.value, submitEvent.target.elements.title.value, submitEvent.target.elements.message.value)
    },
    setOperatorGroupAvailable (available) {
      setOperatorGroupAvailable(available)
    },
    promptMrT (mrT) {
      setMrTShouldCallOperator(mrT.id)
    },
    confiscateMrT () {
      const groupId = (this.currentMrT.group && this.currentMrT.group.id) || 'zentrale'
      addMrTChange(groupId, { ...this.currentMrT, active: false })
    },
    releaseMrT () {
      const groupId = (this.currentMrT.group && this.currentMrT.group.id) || 'zentrale'
      addMrTChange(groupId, { ...this.currentMrT, active: true })
    },
    onSort (field, order) {
      const dir = (order !== 'desc' ? 1 : -1)
      if (field === 'time') {
        this.eventSorter = (a, b) => dir * (a.time.toDate() - b.time.toDate())
      } else if (field === 'group.name') {
        this.eventSorter = (a, b) => dir * this.compareStrings(a.group.name, b.group.name)
      } else if (field === 'type') {
        this.eventSorter = (a, b) => dir * this.compareStrings(this.makeEventComparable(a), this.makeEventComparable(b))
      }
    },
    compareStrings (a, b) {
      if (a < b) return -1
      if (b < a) return 1
      return 0
    },
    makeEventComparable (event) {
      return (event.type === 'station' ? '0_' + event.station.name : (event.type === 'joker' ? '1_' + event.station.name : '2')) + event.time.toDate().getTime()
    },
    createCheckpointToday () {
      const today = new Date()
      const checkpointDate = new Date(today.getFullYear(), today.getMonth(), today.getDate(), ...this.checkpointTime.match(/\d+/g).slice(0, 3), 0)
      createCheckpoint(checkpointDate)
    }
  }
}
</script>
