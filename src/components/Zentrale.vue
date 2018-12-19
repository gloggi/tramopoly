<template>
  <div class="columns is-multiline">
    <tram-header>Zentrale</tram-header>
    <div v-if="loggedInOperatorBusy" class="box column is-full is-one-third-desktop is-offset-one-third-desktop has-text-centered">
      <div>Aktiver Anruf: {{ loggedInOperator['activeCall'] }}</div>
      <button @click="clearActiveCall" class="button is-danger">Aktiven Anruf beenden</button>
    </div>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      <group-list :groups="groups" :loaded="groupsLoaded">
        <template slot-scope="props">
          <b-table-column field="calling" label="Aktion">
            <transition name="fade" mode="out-in">
              <span v-if="props.loaded">
                <router-link class="button btn-primary is-outlined" :to="{ name: 'action', params: { caller: 'test' } }">📞</router-link>
              </span>
            </transition>
          </b-table-column>
        </template>
      </group-list>
    </div>
  </div>
</template>

<script>
import { groupsDB, requireOperator } from '@/firebaseConfig'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import TramHeader from '@/components/TramHeader'
import GroupList from '@/components/GroupList'

export default {
  name: 'Zentrale',
  components: { GroupList, BTableColumn, TramHeader },
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
      return !!(this.$firebaseRefs && this.$firebaseRefs['groups'])
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
    },
    caller (groupKey) {
      return 'test phone number'
    }
  }
}
</script>
