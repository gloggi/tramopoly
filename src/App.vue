<template>
  <div id="app">
    <div v-if="user != null">Willkommä, {{user.phoneNumber}}. <button @click="signout()">Uusloggä</button></div>
    <div v-else><router-link to="/login">Iiloggä</router-link></div>
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
      auth().onAuthStateChanged(user => {
        if (user) {
          this.user = user
        } else {
          this.user = null
        }
      })
    },
    signout () {
      auth().signOut()
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

  @import url('https://fonts.googleapis.com/css?family=Source+Sans+Pro:200,300,400,500,600,300italic');
  $family-sans-serif: "Source Sans Pro", BlinkMacSystemFont, -apple-system, "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", "Helvetica", "Arial", sans-serif;
  $body-family: $family-sans-serif;
  $weight-light: 200;
  $weight-normal: 300;
  $weight-medium: 400;
  $weight-semibold: 500;
  $weight-bold: 600;

  @import "~bulma";
  @import "~buefy/src/scss/buefy";
</style>
