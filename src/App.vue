<template>
  <div id="app">
    <div class="level">
      <div v-if="userIsLoggedIn" class="level-left">
          <span v-if="user.scoutName" class="level-item">Willkommä, {{user.scoutName}}.</span>
          <span v-else class="level-item">Willkommä.</span>
          <button class="button is-outlined level-item" @click="signout()">Uusloggä</button>
      </div>
      <div v-else class="level-left"><router-link to="/login" class="level-item">Iiloggä</router-link></div>
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
    }
  },
  methods: {
    getLoginStatus () {
      auth.onAuthStateChanged(firebaseUser => {
        if (firebaseUser) {
          this.firebaseUser = firebaseUser
        } else {
          this.firebaseUser = null
        }
      })
    },
    signout () {
      auth.signOut()
      this.$router.push('/login')
      this.$unbind('user')
      this.getLoginStatus()
    }
  },
  created () {
    this.getLoginStatus()
    bindUserByPhone(this, 'user', 'firebaseUser.phoneNumber')
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
  $size-1: 4rem;
  $size-2: 3.5rem;
  $size-3: 3rem;
  $size-4: 2.5rem;
  $size-5: 2rem;
  $size-6: 1.5rem;
  $size-7: 1.25rem;

  @import "~bulma";
  @import "~buefy/src/scss/buefy";

  body {
    padding: 1.25rem;
  }

  .button {
    font-weight: $weight-medium;
  }
</style>
