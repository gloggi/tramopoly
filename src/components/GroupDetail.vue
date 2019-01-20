<template>
  <div class="card" v-if="group">
    <header class="card-content has-background-light">
      <slot></slot>
      <b-tag v-if="group.isCurrentlyMrT" type="is-info" class="is-medium is-pulled-right" style="margin-bottom: 10px">Aktuellä Mr. T!</b-tag>
      <div v-if="group.name" style="clear: both">
        <div class="columns is-vcentered is-gapless has-text-left">
          <div v-if="group.abteilung.id" class="column is-narrow is-flex">
            <span class="icon is-large is-left" style="margin-right: 10px"><img :title="group.abteilung.name" style="opacity: 0.7" :src="require('../../static/' + group.abteilung.id + '.svg')"/></span>
          </div>
          <div class="column">
            <div class="columns is-gapless is-mobile">
              <div class="column">
                <h4 class="title is-4">{{ group.name }}</h4>
                <h4 class="subtitle is-6">{{ group.abteilung.name }}</h4>
              </div>
              <div class="column is-narrow has-text-right">
                <div class="title is-4">{{ group.totalPoints }}</div>
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
          <div class="title is-3">{{ group.saldo }}.-</div>
          <div class="subtitle is-6">Guäthabä</div>
        </div>
        <div class="column">
          <div class="title is-3">{{ group.realEstatePoints }}</div>
          <div class="subtitle is-6">Immobiliäpünkt</div>
        </div>
        <div class="column">
          <div class="title is-3">{{ group.mrTPoints }}</div>
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
              <h4 class="subtitle is-6">{{ betterGroup.totalPoints }} Pünkt</h4>
            </div>
          </div>
          <div v-else>
            <h4 class="title is-4" style="clear: left">👑👸 Käi Gruppä isch bessär!</h4>
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
              <h4 class="subtitle is-6">{{ worseGroup.totalPoints }} Pünkt</h4>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
<script>
import BTag from 'buefy/src/components/tag/Tag'

export default {
  name: 'group-detail',
  components: { BTag },
  props: {
    groupId: { type: String },
    allGroups: { type: Array, required: true },
    updateInterval: { type: Number, default: 5 }
  },
  computed: {
    groupIndex () {
      return this.allGroups.findIndex(group => group.id === this.groupId)
    },
    group () {
      if (this.groupIndex === -1) return undefined
      return this.allGroups[this.groupIndex]
    },
    betterGroup () {
      if (!this.group) return undefined
      for (let i = this.groupIndex - 1; i >= 0; i--) {
        if (this.allGroups[i].totalPoints > this.group.totalPoints) {
          return this.allGroups[i]
        }
      }
      return undefined
    },
    worseGroup () {
      if (!this.group) return undefined
      return this.allGroups.find(group => group.totalPoints < this.group.totalPoints)
    }
  }
}
</script>
