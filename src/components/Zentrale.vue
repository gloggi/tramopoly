<template>
  <div class="columns is-multiline">
    <tram-header>Zentralä</tram-header>
    <div v-if="loggedInOperatorBusy" class="box column is-full is-one-third-desktop is-offset-one-third-desktop has-text-centered">
      <div>Aktivä Aruäf: {{ loggedInOperator.activeCall.scoutName }}</div>
      <button @click="clearActiveCall" class="button is-danger">Aktivä Aruäf beändä</button>
    </div>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      <b-table :data="groupsOrDummy" striped hoverable selectable @select="selectGroup">
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
import { groupsDB, requireOperator, setActiveCall } from '@/firebaseConfig'
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
      return !!(this.loggedInOperator && this.loggedInOperator.activeCall)
    }
  },
  methods: {
    clearActiveCall () {
      setActiveCall(this.loggedInOperator.id, null)
    },
    selectGroup (group) {
      this.$router.push({ name: 'action', params: { group: group.id } })
    }
  }
}
</script>
