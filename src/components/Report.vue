<template>
  <div class="columns is-multiline">
    <tram-header>Billet-Kontrollä</tram-header>
    <div class="column is-full has-text-centered">
      <div class="card" v-if="allVisitsCombined.length">
        <header class="card-header has-background-light"><span class="card-header-title title is-4">Billet-Kontrolle</span></header>
        <b-table class="has-content-vcentered" :data="allVisitsCombined" striped hoverable :row-class="hasContentVcentered" backend-sorting @sort="onSort">
          <template slot-scope="props">
            <b-table-column field="group.abteilung.name" label="Abt." sortable>
              <span v-if="props.row.group.abteilung">{{ props.row.group.abteilung.name }}</span>
            </b-table-column>
            <b-table-column field="group.name" label="Gruppä" sortable>
              <span v-if="props.row.group">{{ props.row.group.name }}</span>
            </b-table-column>
            <b-table-column field="time" label="Ziit" sortable>
              {{ props.row.time.toDate().toLocaleTimeString('de-CH') }}
            </b-table-column>
            <b-table-column field="type" label="Aktion" sortable>
              <span v-if="props.row.type === 'joker'" :key="props.row.id">
                <span class="icon">🃏</span>
                <span>{{ props.row.station.name }} (Joker)</span>
              </span>
              <span v-else-if="props.row.type === 'station'" :key="props.row.id">
                <span class="icon">🚉</span>
                <span>{{ props.row.station.name }}</span>
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
  jokerVisitsDB,
  mrTChangesDB,
  requireOperator,
  settingsDB,
  stationVisitsDB,
  usersDB
} from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import TramHeader from '@/components/TramHeader'

export default {
  name: 'Report',
  components: { BTable, BTableColumn, TramHeader },
  props: {
    allGroups: { type: Array, required: true },
    stationOwners: { type: Map, required: true },
    now: { type: Date, required: true }
  },
  data () {
    return {
      loggedInAdmin: null,
      stationVisits: [],
      jokerVisits: [],
      mrTChanges: [],
      settings: null,
      users: [],
      selectedMessageType: 'is-info',
      eventSorter: this.compareGroupsAndTime
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
    allVisitsCombined () {
      return [].concat(
        this.stationVisits.map(visit => ({ ...visit, id: visit.id, type: 'station' }))
          .filter(visit => {
            let owner = this.stationOwners.get(visit.station.id)
            return owner && visit.group.id === owner.id
          }),
        this.jokerVisits.map(visit => ({ ...visit, id: visit.id, type: 'joker' }))
      ).sort(this.eventSorter)
    }
  },
  methods: {
    hasContentVcentered () {
      return 'has-content-vcentered'
    },
    onSort (field, order) {
      let dir = (order !== 'desc' ? 1 : -1)
      if (field === 'time') {
        this.eventSorter = (a, b) => dir * (a.time.toDate() - b.time.toDate())
      } else if (field === 'group.name') {
        this.eventSorter = (a, b) => dir * this.compareStrings(a.group.name, b.group.name)
      } else if (field === 'type') {
        this.eventSorter = (a, b) => dir * this.compareStrings(this.makeEventComparable(a), this.makeEventComparable(b))
      }
    },
    compareGroupsAndTime (a, b) {
      let groupComp = this.compareStrings(a.group.name, b.group.name)
      if (groupComp !== 0) return groupComp
      return a.time.toDate() - b.time.toDate()
    },
    compareStrings (a, b) {
      if (a < b) return -1
      if (b < a) return 1
      return 0
    },
    makeEventComparable (event) {
      return (event.type === 'station' ? '0_' + event.station.name : (event.type === 'joker' ? '1_' + event.station.name : '2')) + event.time.toDate().getTime()
    }
  }
}
</script>
