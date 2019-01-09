<template>
  <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
    Saldo: {{ saldo }}.-
  </div>
</template>
<script>
import { jokerVisitsDB, settingsDB, stationVisitsDB } from '@/firebaseConfig'
import { groupSaldo } from '@/business'

export default {
  name: 'group-detail',
  data () {
    return {
      settings: null,
      stationVisits: [],
      jokerVisits: [],
      now: new Date(),
      saldoTimer: null
    }
  },
  firestore: {
    settings: settingsDB,
    stationVisits: stationVisitsDB,
    jokerVisits: jokerVisitsDB
  },
  props: {
    groupId: { type: String },
    updateInterval: { type: Number, default: 5 }
  },
  methods: {
    updateNow () {
      clearInterval(this.saldoTimer)
      this.now = new Date()
      this.saldoTimer = setInterval(this.updateNow, 1000 * this.updateInterval)
    }
  },
  computed: {
    saldo () {
      return groupSaldo(this.groupId, this.settings, this.stationVisits, this.jokerVisits, this.now)
    }
  },
  created () {
    this.updateNow()
  }
}
</script>
