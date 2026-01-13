<template>
  <div class="column is-full has-text-centered">
    <global-message></global-message>
    <div class="is-flex is-flex-direction-column is-align-items-center is-gap-3">
        <o-switch v-if="mapSize" v-model="displayJokers">Jokärs azeigä</o-switch>
        <o-switch v-if="mapSize" v-model="displayStations">Stationä azeigä</o-switch>
    </div>
    <div class="mt-4" style="position: relative; display: inline-block; overflow: hidden;">
      <img v-if="mapUrl" :src="mapUrl" alt="Übärsichts-Chartä" ref="map" @load="readMapSize" />
      <svg
        v-if="viewBox"
        :viewBox="viewBox"
        style="
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          pointer-events: none;
        "
      >
        <template v-if="displayStations">
          <rect
            v-for="station in stations"
            :key="station.id"
            :id="`station${station.id}`"
            class="station"
            :x="transformX(station.x) - transformSize(10)"
            :y="transformY(station.y) - transformSize(10)"
            :width="transformSize(20)"
            :height="transformSize(20)"
            stroke="black"
            stroke-width="1"
            stroke-opacity="70%"
            fill="white"
            fill-opacity="70%"
          />
        </template>
        <template v-if="displayJokers">
          <circle
            v-for="joker in jokers"
            :key="joker.id"
            :id="`joker${joker.id}`"
            class="joker"
            :cx="transformX(joker.x)"
            :cy="transformY(joker.y)"
            :r="transformSize(12)"
            stroke="black"
            stroke-width="1"
            stroke-opacity="70%"
            fill="white"
            fill-opacity="70%"
          />
        </template>
      </svg>
    </div>
    <global-message></global-message>
  </div>
</template>

<script>
import { useStations } from '../stores/stations'
import { useJokers } from '../stores/jokers'
import useMapUrl from '../composables/useMapUrl'
import GlobalMessage from '../components/GlobalMessage.vue'

export default {
  name: 'MapView',
  components: {
    GlobalMessage,
  },
  data: () => ({
    displayJokers: true,
    displayStations: false,
    xOffset: 33,
    yOffset: 166,
    mapSize: null,
  }),
  computed: {
    loading() {
      return useStations().loading
    },
    mapUrl() {
      const { mapUrl } = useMapUrl()
      return mapUrl.value
    },
    stations() {
      const stationsStore = useStations()
      stationsStore.subscribe()
      return stationsStore.all
    },
    jokers() {
      const jokersStore = useJokers()
      jokersStore.subscribe()
      return jokersStore.all
    },
    viewBox() {
      if (!this.mapSize) return ''
      return `0 0 ${this.mapSize.width} ${this.mapSize.height}`
    },
    scale() {
      if (!this.mapSize) return 1
      return this.mapSize.width / 1130
    },
  },
  methods: {
    readMapSize() {
      this.mapSize = this.$refs.map?.getBoundingClientRect()
    },
    transformX(x) {
      return this.transformSize(x + this.xOffset)
    },
    transformY(y) {
      return this.transformSize(y + this.yOffset)
    },
    transformSize(size) {
      return size * this.scale
    }
  }
}
</script>
