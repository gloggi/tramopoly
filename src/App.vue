<template>
  <div id="app" class="tile is-ancestor is-vertical">
    <div v-if="user != null" class="tile is-parent"><div class="tile is-child">Willkommä, {{user.phoneNumber}}. <a @click="signout()">Uusloggä</a></div></div>
    <div v-else class="tile is-parent"><div class="tile is-child"><router-link to="/login">Iiloggä</router-link></div></div>
    <router-view/>
  </div>
</template>

<script>
import { auth } from '@/firebaseConfig'

export default {
  name: 'Tramopoly',
  data () {
    return {
      user: {}
    }
  },
  methods: {
    getLoginStatus () {
      auth.onAuthStateChanged(user => {
        if (user) {
          this.user = user
        } else {
          this.user = null
        }
      })
    },
    signout () {
      auth.signOut()
      this.$router.push('login')
    }
  },
  updated () {
    this.getLoginStatus()
  },
  created () {
    this.getLoginStatus()
  }
}
</script>

<style lang="scss">
  @import "~bulma/sass/utilities/_all";

  @import url('https://fonts.googleapis.com/css?family=Source+Sans+Pro:200,300,500,600,300italic');
  $family-sans-serif: "Source Sans Pro", BlinkMacSystemFont, -apple-system, "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", "Helvetica", "Arial", sans-serif;
  $body-family: $family-sans-serif;
  $weight-light: 200;
  $weight-normal: 300;
  $weight-medium: 500;
  $weight-semibold: 500;
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
</style>
