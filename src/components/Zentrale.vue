<template>
  <div class="columns is-multiline">
    <tram-header>Zentrale</tram-header>
    <div v-if="loggedInOperatorBusy" class="box column is-full is-one-third-desktop is-offset-one-third-desktop has-text-centered">
      <div>Aktiver Anruf: {{ loggedInOperator['activeCall'] }}</div>
      <button @click="clearActiveCall" class="button is-danger">Aktiven Anruf beenden</button>
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
          <b-table-column field="calling" label="Aktion">
            <transition name="fade" mode="out-in">
              <span v-if="groupsLoaded">
                <router-link class="button btn-primary is-outlined" :to="{ name: 'action', params: { caller: 'test' } }">📞</router-link>
              </span>
            </transition>
          </b-table-column>
        </template>
      </b-table>
    </div>
  </div>
</template>

<script>
import { groupsDB, requireOperator } from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import TramHeader from '@/components/TramHeader'

export default {
  name: 'Zentrale',
  components: { BTable, BTableColumn, TramHeader },
  firestore: {
    groups: groupsDB
  },
  data () {
    return {
      loggedInOperator: null,
      groups: []
    }
  },
  beforeRouteEnter (to, from, next) {
    requireOperator(to, from, next)
  },
  computed: {
    groupsLoaded () {
      return !!(this.$firestoreRefs && this.$firestoreRefs['groups'])
    },
    groupsOrDummy () {
      return this.groupsLoaded ? this.groups : [ {}, {}, {} ]
    },
    loggedInOperatorBusy () {
      return this.loggedInOperator && this.loggedInOperator['activeCall'] !== ''
    }
  },
  methods: {
    clearActiveCall () {
      this.$firestoreRefs.loggedInOperator.child('activeCall').remove()
    },
    deleteGroup (group) {
      groupsDB.child(group['.key']).remove()
    },
    caller (groupKey) {
      return 'test phone number'
    }
  }
}
</script>
