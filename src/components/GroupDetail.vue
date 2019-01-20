<template>
  <div class="card">
    <header class="card-content has-background-light">
      <slot></slot>
      <b-tag v-if="groupIsCurrentlyMrT" type="is-info" class="is-medium is-pulled-right" style="margin-bottom: 10px">Aktuellä Mr. T!</b-tag>
      <div v-if="group.name" style="clear: both">
        <div class="columns is-vcentered is-gapless has-text-left">
          <div v-if="group.abteilung.id" class="column is-narrow is-flex">
            <span class="icon is-large is-left" style="margin-right: 10px"><img style="opacity: 0.7" :src="require('../../static/' + group.abteilung.id + '.svg')"/></span>
          </div>
          <div class="column">
            <div class="columns is-gapless is-mobile">
              <div class="column">
                <h4 class="title is-4">{{ group.name }}</h4>
                <h4 class="subtitle is-6">{{ group.abteilung.name }}</h4>
              </div>
              <div class="column is-narrow has-text-right">
                <div class="title is-4">{{ saldo }}</div>
                <div class="subtitle is-6">Pünkt insgesamt</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </header>
    <div class="card-content">
      <div class="columns is-vcentered">
        <div class="column">
          <div class="title is-3">{{ saldo }}.-</div>
          <div class="subtitle is-6">Guäthabä</div>
        </div>
        <div class="column">
          <div class="title is-3">0</div>
          <div class="subtitle is-6">Immobiliäpünkt</div>
        </div>
        <div class="column">
          <div class="title is-3">0</div>
          <div class="subtitle is-6">Mr. T Pünkt</div>
        </div>
      </div>
    </div>
    <section class="card-content has-background-grey-lighter">
      <div class="columns is-mobile has-text-left">
        <div class="column">
          <div class="title is-6">Die Nächscht&shy;bessärä</div>
          <div v-if="betterGroup" class="columns is-vcentered is-gapless">
            <div class="column is-narrow is-flex">
              <span class="icon is-large is-left" style="margin-right: 10px"><img :title="betterGroup.abteilung.name" style="opacity: 0.7" :src="require('../../static/' + betterGroup.abteilung.id + '.svg')"/></span>
            </div>
            <div class="column">
              <h4 class="title is-4" style="clear: left">{{ betterGroup.name }}</h4>
              <h4 class="subtitle is-6">{{ betterGroup.saldo }} Pünkt</h4>
            </div>
          </div>
          <div v-else>
            <h4 class="title is-4" style="clear: left">Käi Gruppä isch bessär!</h4>
          </div>
        </div>
        <div class="column" v-if="worseGroup">
          <div class="title is-6">Die Nächscht&shy;schlächtärä</div>
          <div class="columns is-vcentered is-gapless">
            <div class="column is-narrow is-flex">
              <span class="icon is-large is-left" style="margin-right: 10px"><img :title="worseGroup.abteilung.name" style="opacity: 0.7" :src="require('../../static/' + worseGroup.abteilung.id + '.svg')"/></span>
            </div>
            <div class="column">
              <h4 class="title is-4" style="clear: left">{{ worseGroup.name }}</h4>
              <h4 class="subtitle is-6">{{ worseGroup.saldo }} Pünkt</h4>
            </div>
          </div>
        </div>
      </div>
    </section>
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
    group: { type: Object },
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
      return this.group && groupSaldo(this.group.id, this.settings, this.stationVisits, this.jokerVisits, this.now)
    },
    groupIsCurrentlyMrT () {
      return this.group && this.group.id && this.currentMrT.length && this.currentMrT[0].group.id === this.group.id
    },
    betterGroup () {
      return null
    },
    worseGroup () {
      return null
    }
  },
  created () {
    this.updateNow()
  }
}
</script>
