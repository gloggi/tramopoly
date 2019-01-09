<template>
  <div class="columns is-multiline">
    <tram-header>Dashboard</tram-header>
    <div v-if="operator != null" class="box column is-full is-one-third-desktop is-offset-one-third-desktop has-text-centered">
      <button v-if="!operatorBusy" class="button is-link is-outlined" @click="callOperator">📞 Zentralä ({{ operatorName }})</button>
      <button v-else-if="loggedInUserIsActiveCaller" class="button is-link is-outlined is-danger" @click="finishCall">🚫 Färtig telefoniärt</button>
      <button v-else class="button is-link is-outlined" @click="callOperator">🚫 Zentralä ({{ operatorName }} bsetzt)</button>
    </div>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      Saldo: {{ saldo }}.-
    </div>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      <b-table :data="groupsOrDummy" striped hoverable>
        <template slot-scope="props">
          <b-table-column field="name" label="Gruppä">
            <transition name="fade" mode="out-in">
              <span v-if="groupsLoaded">{{ props.row.name }}</span>
              <placeholder v-else></placeholder>
            </transition>
          </b-table-column>
          <b-table-column field="abteilung" label="Abteilig">
            <transition name="fade" mode="out-in">
              <span v-if="groupsLoaded">{{ props.row.abteilung.name }}</span>
              <placeholder v-else></placeholder>
            </transition>
          </b-table-column>
        </template>
      </b-table>
    </div>
  </div>
</template>

<script>
import {
  abteilungenDB,
  bindUserById,
  groupsDB, jokerVisitsDB,
  requireAuth,
  setActiveCall,
  settingsDB,
  stationVisitsDB
} from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import BIcon from 'buefy/src/components/icon/Icon'
import Placeholder from '@/components/Placeholder'
import TramHeader from '@/components/TramHeader'
import { groupSaldo } from '@/business'

export default {
  name: 'Dashboard',
  components: { Placeholder, BIcon, BTable, BTableColumn, TramHeader },
  data () {
    return {
      loggedInUser: null,
      groups: [],
      abteilungen: [],
      settings: null,
      stationVisits: [],
      jokerVisits: [],
      operator: null,
      now: new Date(),
      saldoTimer: null
    }
  },
  firestore: {
    groups: groupsDB,
    abteilungen: abteilungenDB,
    settings: settingsDB,
    stationVisits: stationVisitsDB,
    jokerVisits: jokerVisitsDB
  },
  beforeRouteEnter (to, from, next) {
    requireAuth(to, from, next)
  },
  computed: {
    groupsLoaded () {
      return !!(this.$firestoreRefs && this.$firestoreRefs['groups'])
    },
    groupsOrDummy () {
      return this.groupsLoaded ? this.groups : [ {}, {}, {} ]
    },
    operatorName () {
      return this.operator ? this.operator.scoutName : null
    },
    operatorPhone () {
      return this.operator ? this.operator.phone : null
    },
    operatorId () {
      return this.operator ? this.operator.id : null
    },
    operatorBusy () {
      return !!(this.operator && this.operator.activeCall)
    },
    loggedInUserIsActiveCaller () {
      return this.operatorBusy && this.operator.activeCall.id === this.loggedInUser.id
    },
    saldo () {
      return groupSaldo(this.loggedInUser.group.id, this.settings, this.stationVisits, this.jokerVisits, this.now)
    }
  },
  methods: {
    updateNow () {
      clearInterval(this.saldoTimer)
      this.now = new Date()
      this.saldoTimer = setInterval(this.updateNow, 1000 * 5)
    },
    callOperator () {
      setActiveCall(this.operatorId, this.loggedInUser.id).then(() => {
        window.location = 'tel:' + this.operatorPhone
      })
    },
    finishCall () {
      if (this.loggedInUserIsActiveCaller) {
        setActiveCall(this.operatorId, null)
      }
    }
  },
  created () {
    this.updateNow()
  },
  watch: {
    'loggedInUser.group.abteilung.operator': function (newOperator) {
      if (newOperator.id) {
        bindUserById(this, 'operator', newOperator.id)
      }
    }
  }
}
</script>

<style scoped>
  .fade-enter-active, .fade-leave-active {
    transition: opacity .2s;
    position: absolute;
  }
  .fade-enter, .fade-leave-to {
    opacity: 0;
  }
</style>
