<template>
  <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
    <b-tag v-if="groupIsCurrentlyMrT" type="is-info is-medium" style="float: right">Miär sind Mr. T!</b-tag>
    Saldo: {{ saldo }}.-
  </div>
</template>
<script>
import { currentMrTDB, jokerVisitsDB, settingsDB, stationVisitsDB } from '@/firebaseConfig'
import { groupSaldo } from '@/business'
import BTag from 'buefy/src/components/tag/Tag'

export default {
  name: 'group-detail',
  components: { BTag },
  data () {
    return {
      settings: null,
      stationVisits: [],
      jokerVisits: [],
      currentMrT: [],
      now: new Date(),
      saldoTimer: null
    }
  },
  firestore: {
    settings: settingsDB,
    stationVisits: stationVisitsDB,
    jokerVisits: jokerVisitsDB,
    currentMrT: currentMrTDB
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
    },
    groupIsCurrentlyMrT () {
      return this.groupId && this.currentMrT.length && this.currentMrT[0].group.id === this.groupId
    }
  },
  created () {
    this.updateNow()
  }
}
</script>
