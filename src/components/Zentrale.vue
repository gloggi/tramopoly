<template>
  <div class="columns is-multiline">
    <header class="title has-text-centered column is-full">Zentrale</header>
    <div v-if="loggedInOperatorBusy" class="box column is-full is-one-third-desktop is-offset-one-third-desktop has-text-centered">
      <div>Aktiver Anruf: {{ loggedInOperator['activeCall'] }}</div>
      <button @click="clearActiveCall" class="button is-danger">Aktiven Anruf beenden</button>
    </div>
  </div>
</template>

<script>
import { requireOperator } from '@/firebaseConfig'

export default {
  name: 'Zentrale',
  data () {
    return {
      loggedInOperator: null
    }
  },
  beforeRouteEnter (to, from, next) {
    requireOperator(to, from, next)
  },
  computed: {
    loggedInOperatorBusy () {
      return this.loggedInOperator && this.loggedInOperator['activeCall'] !== undefined
    }
  },
  methods: {
    clearActiveCall () {
      this.$firebaseRefs.loggedInOperator.child('activeCall').remove()
    }
  }
}
</script>
