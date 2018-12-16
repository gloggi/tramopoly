<template>
  <div class="columns is-multiline">
    <tram-header>Dashboard</tram-header>
    <div v-if="operator != null" class="box column is-full is-one-third-desktop is-offset-one-third-desktop has-text-centered">
      <button v-if="!operatorBusy" class="button is-link is-outlined" @click="callOperator">📞 Zentrale ({{ operatorName }})</button>
      <button v-else-if="loggedInUserIsActiveCaller" class="button is-link is-outlined is-danger" @click="finishCall">🚫 Meinen Anruf beenden</button>
      <button v-else class="button is-link is-outlined" @click="callOperator">🚫 Zentrale ({{ operatorName }} besetzt)</button>
    </div>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      <group-list :groups="groups" :loaded="groupsLoaded"></group-list>
    </div>
  </div>
</template>

<script>
import { bindUserByPhone, groupsDB, abteilungenDB, requireAuth } from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import BIcon from 'buefy/src/components/icon/Icon'
import Placeholder from '@/components/Placeholder'
import TramHeader from '@/components/TramHeader'
import GroupList from '@/components/GroupList'

export default {
  name: 'Dashboard',
  components: { GroupList, Placeholder, BIcon, BTable, BTableColumn, TramHeader },
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
      return !!(this.$firebaseRefs && this.$firebaseRefs['groups'])
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
      return this.operator['activeCall'] !== undefined
    },
    loggedInUserIsActiveCaller () {
      return this.operatorBusy && this.operator['activeCall'] === this.loggedInUser['.key']
    }
  },
  watch: {
    operatorPhone: function () {
      if (!this.operatorPhone) {
        if (this.$firebaseRefs['operator']) {
          this.$unbind('operator')
        }
      } else {
        bindUserByPhone(this, 'operator', 'operatorPhone')
      }
    }
  },
  methods: {
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
