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
