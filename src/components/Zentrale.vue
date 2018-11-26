<template>
  <div class="columns is-multiline">
    <header class="title has-text-centered column is-full">Zentrale</header>
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
              <span v-if="groupsLoaded">{{ props.row.abteilung }}</span>
              <placeholder v-else></placeholder>
            </transition>
          </b-table-column>
          <b-table-column field="delete" label="" width="44">
            <transition name="fade" mode="out-in">
              <button v-if="groupsLoaded" class="button is-small is-danger is-outlined" @click="deleteGroup(props.row)">🗑️</button>
              <button v-else class="button is-small is-danger is-outlined" disabled>🗑️</button>
            </transition>
          </b-table-column>
        </template>
      </b-table>
    </div>
  </div>
</template>

<script>
import { requireOperator, groupsDB } from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import BIcon from 'buefy/src/components/icon/Icon'
import Placeholder from '@/components/Placeholder'

export default {
  name: 'Zentrale',
  components: { Placeholder, BIcon, BTable, BTableColumn },
  firebase: {
    groups: groupsDB
  },
  data () {
    return {
      loggedInOperator: null
    }
  },
  beforeRouteEnter (to, from, next) {
    requireOperator(to, from, next)
  },
  computed: {
    groupsLoaded () {
      return this.groups && this.groups.length
    },
    groupsOrDummy () {
      return this.groupsLoaded ? this.groups : [{}, {}, {}, {}, {}]
    },
    loggedInOperatorBusy () {
      return this.loggedInOperator && this.loggedInOperator['activeCall'] !== undefined
    }
  },
  methods: {
    clearActiveCall () {
      this.$firebaseRefs.loggedInOperator.child('activeCall').remove()
    },
    deleteGroup (group) {
      groupsDB.child(group['.key']).remove()
    }
  }
}
</script>
