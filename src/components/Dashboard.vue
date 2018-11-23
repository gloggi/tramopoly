<template>
  <div class="columns is-multiline">
    <header class="title has-text-centered column is-full">Dashboard</header>
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
import { bindUserByPhone, groupsDB, abteilungenDB, requireAuth } from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import BIcon from 'buefy/src/components/icon/Icon'
import Placeholder from '@/components/Placeholder'

export default {
  name: 'Dashboard',
  components: { Placeholder, BIcon, BTable, BTableColumn },
  firebase: {
    groups: groupsDB,
    abteilungen: abteilungenDB
  },
  data () {
    return {
      loggedInUser: null,
      operator: null
    }
  },
  beforeRouteEnter (to, from, next) {
    requireAuth(to, from, next)
  },
  computed: {
    groupsLoaded () {
      return this.groups && this.groups.length
    },
    groupsOrDummy () {
      return this.groupsLoaded ? this.groups : [{}, {}, {}, {}, {}]
    },
    operatorName () {
      return this.operator ? this.operator['scoutName'] : null
    },
    operatorPhone () {
      if (!this.loggedInUser || !this.loggedInUser['groupName'] || !this.groups) {
        return null
      }
      let groupOfLoggedInUser = this.groups.find(g => g['name'] === this.loggedInUser['groupName'])
      if (!groupOfLoggedInUser || !groupOfLoggedInUser['abteilung'] || !this.abteilungen) {
        return null
      }
      let abteilungOfLoggedInUser = this.abteilungen.find(a => a['name'] === groupOfLoggedInUser['abteilung'])
      if (!abteilungOfLoggedInUser || !abteilungOfLoggedInUser['operatorPhone']) {
        return null
      }
      return abteilungOfLoggedInUser['operatorPhone']
    },
    operatorBusy () {
      console.log(this.operator['activeCall'])
      return this.operator['activeCall'] !== undefined
    },
    loggedInUserIsActiveCaller () {
      return this.operatorBusy && this.operator['activeCall'] === this.loggedInUser['.key']
    }
  },
  watch: {
    operatorPhone: function () {
      if (!this.operatorPhone) {
        if (this.operator) {
          this.$unbind('operator')
        }
      } else {
        bindUserByPhone(this, 'operator', 'operatorPhone')
      }
    }
  },
  methods: {
    deleteGroup (group) {
      groupsDB.child(group['.key']).remove()
    },
    callOperator () {
      this.$firebaseRefs.operator.child('activeCall').set(this.loggedInUser['.key'])
      setTimeout(() => { window.location = 'tel:' + this.operatorPhone }, 300)
    },
    finishCall () {
      if (this.loggedInUserIsActiveCaller) {
        this.$firebaseRefs.operator.child('activeCall').remove()
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
