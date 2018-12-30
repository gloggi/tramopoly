<template>
  <div class="columns is-multiline">
    <tram-header>Dashboard</tram-header>
    <div v-if="operator != null" class="box column is-full is-one-third-desktop is-offset-one-third-desktop has-text-centered">
      <button v-if="!operatorBusy" class="button is-link is-outlined" @click="callOperator">📞 Zentrale ({{ operatorName }})</button>
      <button v-else-if="loggedInUserIsActiveCaller" class="button is-link is-outlined is-danger" @click="finishCall">🚫 Meinen Anruf beenden</button>
      <button v-else class="button is-link is-outlined" @click="callOperator">🚫 Zentrale ({{ operatorName }} besetzt)</button>
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
import { groupsDB, abteilungenDB, requireAuth } from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import BIcon from 'buefy/src/components/icon/Icon'
import Placeholder from '@/components/Placeholder'
import TramHeader from '@/components/TramHeader'

export default {
  name: 'Dashboard',
  components: { Placeholder, BIcon, BTable, BTableColumn, TramHeader },
  firestore: {
    groups: groupsDB,
    abteilungen: abteilungenDB
  },
  data () {
    return {
      loggedInUser: null,
      groups: [],
      abteilungen: []
    }
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
    operator () {
      if (!this.loggedInUser || !this.loggedInUser.group || !this.loggedInUser.group.abteilung) {
        return null
      }
      let loggedInUserAbteilung = this.abteilungen.find(abteilung => abteilung.name === this.loggedInUser.group.abteilung.name)
      if (!loggedInUserAbteilung || !loggedInUserAbteilung.operator) {
        return null
      }
      return loggedInUserAbteilung.operator
    },
    operatorName () {
      return this.operator ? this.operator.scoutName : null
    },
    operatorPhone () {
      return this.operator ? this.operator.phone : null
    },
    operatorBusy () {
      return this.operator !== null && this.operator.activeCall !== ''
    },
    loggedInUserIsActiveCaller () {
      return this.operatorBusy && this.operator.activeCall === this.loggedInUser.phone
    }
  },
  methods: {
    callOperator () {
      this.$firestoreRefs.operator.child('activeCall').set(this.loggedInUser.phone)
      setTimeout(() => { window.location = 'tel:' + this.operatorPhone }, 300)
    },
    finishCall () {
      if (this.loggedInUserIsActiveCaller) {
        this.$firestoreRefs.operator.child('activeCall').remove()
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
