<template>
  <div class="column is-full has-text-centered">
    <global-message></global-message>
    <o-slider
      :model-value="time"
      :tooltip="false"
      size="large"
      @update:model-value="updateAnimation"
      @change="pauseAnimationAt"
    />
    <div style="position: relative; display: inline-block">
      <img
        v-if="mapUrl"
        :src="mapUrl"
        style="opacity: 0.5"
        alt="Chartä mit dä Gruppä"
        @click="playOrPause"
      />
      <svg
        viewBox="0 0 1122.5201 1451.3386"
        style="
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          pointer-events: none;
        "
      >
        <rect
          v-for="station in stations"
          :key="station.id"
          :id="`station${station.id}`"
          class="station"
          :x="station.x - 15"
          :y="station.y - 15"
          width="30"
          height="30"
          stroke="black"
          stroke-width="1"
          fill="white"
          fill-opacity="70%"
        />
        <g v-for="group in groups" :key="group.id" :id="group.id">
          <circle
            class="group"
            cx="0"
            cy="0"
            r="10"
            :style="{ fill: group.color }"
          ></circle>
          <image :href="group.logoUrl" width="20" height="20" x="-10" y="-10" />
        </g>
      </svg>
    </div>
    <global-message></global-message>
  </div>
</template>

<script setup>
import useMapUrl from '@/composables/useMapUrl.js'
import GlobalMessage from '@/components/GlobalMessage.vue'
import { useUserSession } from '@/stores/userSession'
import { storeToRefs } from 'pinia'
import { useRouter } from 'vue-router'

const userSession = useUserSession()
const { isPlayer } = storeToRefs(userSession)

if (isPlayer.value) {
  const router = useRouter()
  router.replace({ name: 'dashboard' })
}

const { mapUrl } = useMapUrl()
</script>

<script>
import { gsap } from 'gsap'
import { useGroups } from '@/stores/groups'
import { useJokerVisits } from '@/stores/jokerVisits'
import { useStationVisits } from '@/stores/stationVisits'
import { useSettings } from '@/stores/settings'
import { useStations } from '@/stores/stations'

export default {
  name: 'MapView',
  data: () => ({
    startX: 580,
    startY: 855,
    animations: null,
    time: 0,
  }),
  computed: {
    settings() {
      const settingsStore = useSettings()
      settingsStore.subscribe()
      return settingsStore.entry
    },
    stations() {
      const stationsStore = useStations()
      stationsStore.subscribe()
      return stationsStore.all
    },
    allGroups() {
      const groupsStore = useGroups({
        select: '*,abteilung:abteilungen(*)',
        filter: { active: true },
      })
      groupsStore.subscribe()
      return groupsStore.all
    },
    stationVisits() {
      const stationVisitsStore = useStationVisits({
        select:
          '*,is_purchase,is_duplicate,group:group_id(*),station:station_id(*)',
      })
      stationVisitsStore.subscribe()
      return stationVisitsStore.all.filter((sv) => sv.acceptedAt)
    },
    jokerVisits() {
      const jokerVisitsStore = useJokerVisits()
      jokerVisitsStore.subscribe()
      return jokerVisitsStore.all.filter((jv) => jv.acceptedAt)
    },
    allLocationsByGroup() {
      if (!this.settings) return {}
      const allLocations = this.stationVisits
        .map((sv) => ({
          groupId: sv.groupId,
          time: (sv.createdAt - this.settings.gameStart) / 60000,
          x: sv.station.x || Math.random() * 800,
          y: sv.station.y || Math.random() * 1500,
          purchasedStationId:
            sv.isPurchase && sv.acceptedAt && !sv.isDuplicate
              ? sv.stationId
              : null,
        }))
        .concat(
          this.jokerVisits.map((jv) => ({
            groupId: jv.groupId,
            time: (jv.createdAt - this.settings.gameStart) / 60000,
            x: jv.joker.x || Math.random() * 800,
            y: jv.joker.y || Math.random() * 1500,
          }))
        )
        .filter((location) => location.x && location.y)
      allLocations.sort((a, b) => a.time - b.time)
      return allLocations.reduce((grouped, location) => {
        if (!(location.groupId in grouped)) grouped[location.groupId] = []
        grouped[location.groupId].push(location)
        return grouped
      }, {})
    },
    abteilungColors() {
      const abteilungen = this.allGroups.reduce((abteilungen, group) => {
        if (!abteilungen.includes(group.abteilungId))
          return [...abteilungen, group.abteilungId]
        return abteilungen
      }, [])
      const colors = ['lightblue', 'purple', 'green', 'orange', 'yellow', 'red']
      return Object.fromEntries(
        abteilungen.map((id, index) => [id, colors[index % colors.length]])
      )
    },
    groups() {
      return this.allGroups.map((group) => {
        return {
          name: group.name,
          id: `group${group.id}`,
          logoUrl: group.abteilung.logoUrl,
          color: this.abteilungColors[group.abteilungId],
          positions: this.allLocationsByGroup[group.id] || [],
        }
      })
    },
  },
  methods: {
    setupAnimations() {
      const animations = gsap.timeline({
        onComplete: () => {
          animations.pause()
        },
      })
      animations.set('.stations', { fill: 'white' }, 0)
      this.groups.forEach((group) => {
        const animation = gsap.timeline({
          onUpdate: this.updateSlider,
          defaults: { ease: 'power1.inOut' },
        })
        let previousTime = 0
        animation.set(`#${group.id}`, { x: this.startX, y: this.startY })
        group.positions.forEach((position) => {
          animation.to(`#${group.id}`, {
            x: position.x,
            y: position.y,
            duration: position.time - previousTime,
          })
          if (position.purchasedStationId) {
            animation.set(`#station${position.purchasedStationId}`, {
              fill: group.color,
            })
          }
          previousTime = position.time
        })
        animations.add(animation, 0)
      })
      animations.timeScale(animations.duration() / 10)
      animations.progress(1).pause()
      this.time = 100
      this.animations = animations
    },
    playOrPause() {
      if (this.animations.progress() === 1) {
        this.animations.progress(0).play()
        return null
      }
      this.animations.paused()
        ? this.animations.play()
        : this.animations.pause()
    },
    updateSlider() {
      this.time = 100 * this.animations.progress()
    },
    updateAnimation(time) {
      if (!this.animations) return
      this.animations.progress(time / 100)
    },
    pauseAnimationAt(time) {
      if (!this.animations) return
      this.animations.progress(time / 100).pause()
    },
  },
  watch: {
    groups() {
      if (!this.groups.length) return
      this.$nextTick(() => {
        this.setupAnimations()
        this.animations.pause()
      })
    },
  },
}
</script>
