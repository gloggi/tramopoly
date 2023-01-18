<template>
  <div class="card" v-if="!loading">
    <header class="card-content has-background-light">
      <slot></slot>
      <span
        v-if="group.isCurrentlyMrT"
        class="tag is-info is-medium is-pulled-right mb-2"
        >Aktuellä Mr. T!</span
      >
      <div v-if="group.name" style="clear: both">
        <div class="columns is-vcentered is-gapless has-text-left">
          <div v-if="group.abteilung.id" class="column is-narrow is-flex">
            <span class="icon is-large is-left" style="margin-right: 10px"
              ><img
                :title="group.abteilung.name"
                style="opacity: 0.7"
                :src="group.abteilung.logoUrl"
            /></span>
          </div>
          <div class="column">
            <div class="columns is-gapless is-mobile">
              <div class="column">
                <h4 class="title is-4">{{ group.name }}</h4>
                <h4 class="subtitle is-6">{{ group.abteilung.name }}</h4>
              </div>
              <div class="column is-narrow has-text-right">
                <div class="title is-4">
                  {{ groupScoresStore.totals[groupId] }}
                </div>
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
          <div class="title is-3">
            {{ groupScoresStore.balances[groupId] }}.-
            <span class="tag is-info is-small mb-2"
              >+{{ interestPerMinute }}.-/min</span
            >
          </div>
          <div class="subtitle is-6">Guäthabä</div>
        </div>
        <div class="column">
          <div class="title is-3">
            {{ groupScoresStore.realEstatePoints[groupId] }}
          </div>
          <div class="subtitle is-6">Immobiliä&shy;pünkt</div>
        </div>
        <div class="column">
          <div class="title is-3">
            {{ groupScoresStore.mrTPoints[groupId] }}
          </div>
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
              <span class="icon is-large is-left" style="margin-right: 10px"
                ><img
                  :title="betterGroup.abteilung.name"
                  style="opacity: 0.7"
                  :src="'/' + betterGroup.abteilung.id + '.svg'"
              /></span>
            </div>
            <div class="column">
              <h4 class="title is-4" style="clear: left">
                {{ betterGroup.name }}
              </h4>
              <h4 class="subtitle is-6">{{ betterGroup.totalPoints }} Pünkt</h4>
            </div>
          </div>
          <div v-else>
            <h4 class="title is-4" style="clear: left">
              👑👸 Käi Gruppä isch bessär!
            </h4>
          </div>
        </div>
        <div class="column" v-if="worseGroup">
          <div class="title is-6">Die Nächscht&shy;schlächtärä</div>
          <div class="columns is-vcentered is-gapless">
            <div class="column is-narrow is-flex">
              <span class="icon is-large is-left" style="margin-right: 10px"
                ><img
                  :title="worseGroup.abteilung.name"
                  style="opacity: 0.7"
                  :src="'/' + worseGroup.abteilung.id + '.svg'"
              /></span>
            </div>
            <div class="column">
              <h4 class="title is-4" style="clear: left">
                {{ worseGroup.name }}
              </h4>
              <h4 class="subtitle is-6">{{ worseGroup.totalPoints }} Pünkt</h4>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { useGroup } from '@/stores/groups'
import { storeToRefs } from 'pinia'
import { toRefs, computed, onMounted } from 'vue'
import { useGroupScores } from '@/stores/groupScores'

const props = defineProps({
  groupId: { type: Number, required: true },
})

const { groupId } = toRefs(props)

const groupStore = useGroup(groupId.value)
groupStore.subscribe()
const { loading: groupsLoading, entry: group } = storeToRefs(groupStore)

const groupScoresStore = useGroupScores()
groupScoresStore.subscribe()
const { loading: groupScoresLoading } = storeToRefs(groupScoresStore)
onMounted(() => {
  groupScoresStore.fetch(true)
})

const loading = computed(() => groupsLoading.value || groupScoresLoading.value)
const interestPerMinute = computed(() =>
  Math.round(groupScoresStore.interestRates[groupId.value] * 60)
)

// TODO
const betterGroup = null
const worseGroup = null
</script>

<script>
export default {
  name: 'GroupDetail',
}
</script>
