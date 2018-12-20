<template>
  <div id="app">
    <div class="level">
      <div class="level-left">
        <span v-if="userIsLoggedIn && user.scoutName" class="level-item">Willkommä, {{user.scoutName}}.</span>
        <span v-else-if="userIsLoggedIn" class="level-item">Willkommä.</span>
        <a v-if="userIsLoggedIn" class="level-item" @click="signout()">Uusloggä</a>
        <router-link v-else :to="{ name: 'login' }" class="level-item">Iiloggä</router-link>
        <router-link v-if="userIsOperator" :to="{ name: 'zentrale' }" class="level-item">Zentrale</router-link>
      </div>
    </div>
    <router-view/>
  </div>
</template>

<script>
import { auth, bindUserByPhone } from '@/firebaseConfig'

export default {
  name: 'Tramopoly',
  data () {
    return {
      firebaseUser: {},
      user: null
    }
  },
  computed: {
    userIsLoggedIn () {
      return this.user !== null
    },
    userIsOperator () {
      return this.userIsLoggedIn && this.user['isOperator']
    }
  },
  methods: {
    getLoginStatus (onLoginStatusAvailable = null) {
      auth.onAuthStateChanged(firebaseUser => {
        if (firebaseUser) {
          this.firebaseUser = firebaseUser
        } else {
          this.firebaseUser = null
        }
        if (onLoginStatusAvailable !== null) {
          onLoginStatusAvailable(firebaseUser)
        }
      })
    },
    signout () {
      auth.signOut()
      this.$router.push({ name: 'login' })
      if (this.$firestoreRefs['user']) {
        this.$unbind('user')
      }
      this.getLoginStatus()
    }
  },
  created () {
    this.getLoginStatus(() => bindUserByPhone(this, 'user', 'firebaseUser.phoneNumber'))
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
</style>
