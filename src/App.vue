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
    <router-view @login="refreshLoginStatus"/>
  </div>
</template>

<script>
import { auth, bindUserById } from '@/firebaseConfig'

export default {
  name: 'Tramopoly',
  data () {
    return {
      firestoreUser: {},
      user: null
    }
  },
  computed: {
    userIsLoggedIn () {
      return this.user !== null
    },
    userIsOperator () {
      return this.userIsLoggedIn && this.user.isOperator
    }
  },
  methods: {
    refreshLoginStatus () {
      return new Promise(resolve => {
        auth.onAuthStateChanged(firestoreUser => {
          if (firestoreUser) {
            this.firestoreUser = firestoreUser
            bindUserById(this, 'user', firestoreUser.uid)
          } else {
            this.firestoreUser = {}
            bindUserById(this, 'user', null)
          }
          resolve(firestoreUser)
        })
      })
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
    }
  },
  created () {
    this.refreshLoginStatus()
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
</style>
