<template>
  <div id="app">
    <div class="level">
      <div class="level-left">
        <span v-if="userIsLoggedIn && user.scoutName" class="level-item">Willkommä, {{user.scoutName}}.</span>
        <span v-else-if="userIsLoggedIn" class="level-item">Willkommä.</span>
        <a v-if="userIsLoggedIn" class="level-item" @click="signout">Uusloggä</a>
        <router-link v-else :to="{ name: 'login' }" class="level-item">Iiloggä</router-link>
        <router-link v-if="userIsOperator" :to="{ name: 'zentrale' }" class="level-item">Zentralä</router-link>
        <a class="level-item" @click="support">Hilfe</a>
      </div>
    </div>
    <router-view @login="refreshLoginStatus" @update="updateNow" :all-groups="allGroups" :station-owners="stationOwners" :mr-t-location="mrTLocation"/>
  </div>
</template>

<script>
import {
  auth,
  bindUserById,
  groupsDB,
  jokerVisitsDB,
  mrTChangesDB,
  settingsDB,
  stationVisitsDB
} from '@/firebaseConfig'
import { calculateAllScores, renderMrTLocation } from '@/business'

export default {
  name: 'Tramopoly',
  data () {
    return {
      firestoreUser: {},
      user: null,
      groups: [],
      stationVisits: [],
      jokerVisits: [],
      mrTChanges: [],
      settings: null,
      now: new Date(),
      saldoTimer: null
    }
  },
  firestore: {
    groups: groupsDB
  },
  computed: {
    userIsLoggedIn () {
      return this.user !== null
    },
    userIsOperator () {
      return this.userIsLoggedIn && this.user.isOperator
    },
    allGroupsAndStationOwners () {
      if (!this.userIsLoggedIn ||
        (this.groups.length && this.groups.some(group => !(group.abteilung && group.abteilung.id))) ||
        !this.$firestoreRefs['settings'] || !this.$firestoreRefs['stationVisits'] || !this.$firestoreRefs['jokerVisits'] || !this.$firestoreRefs['mrTChanges']
      ) {
        return { allGroups: [], stationOwners: new Map() }
      }
      return calculateAllScores(this.groups, this.stationVisits, this.jokerVisits, this.mrTChanges, this.settings, this.now)
    },
    allGroups () {
      return this.allGroupsAndStationOwners.allGroups
    },
    stationOwners () {
      return this.allGroupsAndStationOwners.stationOwners
    },
    mrTLocation () {
      return renderMrTLocation(this.mrTChanges, this.now)
    }
  },
  methods: {
    refreshLoginStatus () {
      return new Promise(resolve => {
        auth.onAuthStateChanged(firestoreUser => {
          if (firestoreUser) {
            this.firestoreUser = firestoreUser
            bindUserById(this, 'user', firestoreUser.uid).then(this.bindRestrictedCollections)
          } else {
            this.firestoreUser = {}
            bindUserById(this, 'user', null)
          }
          resolve(firestoreUser)
        })
      })
    },
    bindRestrictedCollections () {
      this.$bind('stationVisits', stationVisitsDB)
      this.$bind('jokerVisits', jokerVisitsDB)
      this.$bind('mrTChanges', mrTChangesDB)
      this.$bind('settings', settingsDB)
    },
    async signout () {
      auth.signOut()
      await this.refreshLoginStatus()
      this.$router.push({ name: 'login' })
    },
    support () {
      this.$snackbar.open({
        message: 'Lüüt am Cosinus aa: Null Sibä Nüün, Drüü Acht Sächs, Sächs Sibä, Null Sächs',
        position: 'is-top',
        indefinite: true
      })
    },
    updateNow () {
      clearInterval(this.saldoTimer)
      this.now = new Date()
      this.saldoTimer = setInterval(this.updateNow, 1000 * 10)
    }
  },
  created () {
    this.refreshLoginStatus().then(() => this.updateNow())
  }
}
</script>

<style lang="scss">
  @import "~bulma/sass/utilities/_all";

  @import url('https://fonts.googleapis.com/css?family=Source+Sans+Pro:200,300,600,300italic');
  $family-sans-serif: "Source Sans Pro", BlinkMacSystemFont, -apple-system, "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", "Helvetica", "Arial", sans-serif;
  $body-family: $family-sans-serif;
  $weight-light: 200;
  $weight-normal: 300;
  $weight-medium: 600;
  $weight-semibold: 600;
  $weight-bold: 600;
  $size-4: 1.75rem;
  $size-5: 1.5rem;
  $size-6: 1.25rem;
  $size-7: 1rem;

  @import "~bulma";
  @import "~buefy/src/scss/buefy";

  body {
    padding: 1.25rem;
  }

  .button {
    font-weight: $weight-medium;
  }

  .column.panel {
    padding: 0;
  }

  .card {
    margin-bottom: 1.5rem;
  }

  tr.is-clickable {
    cursor: pointer;
  }

  .panel-block.is-strikethrough {
    color: $grey-light;
  }

  .panel-block span {
    margin-right: 0.3em;
  }

  tr.is-active-call {
    background: $green !important;
  }

  tr.has-content-vcentered td {
    vertical-align: middle;
  }
</style>
