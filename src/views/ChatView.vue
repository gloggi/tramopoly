<template>
  <div ref="top" style="width: 100%; height: 0" />
  <div class="fullscreen-chat" :style="{ top: chatTop + 'px' }">
    <group-chat
      :group-id="groupId"
      :messages="allChatContent"
      :messages-loaded="allChatContentLoaded"
      init-message="Willkommä bim Tramopoly-Chät 💬 Da chasch mit de Zentralä kommuniziärä. Mit äm Tram-Chnopf chasch Stationä und Jokärs bsuächä ↴"
      @fetch-messages="fetchMoreChatContent"
      @textarea-action-handler="modalOpen = true"
      @toggle-rooms-list="$router.push({ name: 'dashboard' })"
    >
      <template
        v-for="stationVisit in stationVisits"
        #[`message_${stationVisit.id}`]
        :key="stationVisit.id"
      >
        <station-visit-message
          :station-visit="stationVisit"
          :group-id="groupId"
        ></station-visit-message>
      </template>
      <template
        v-for="jokerVisit in jokerVisits"
        #[`message_${jokerVisit.id}`]
        :key="jokerVisit.id"
      >
        <joker-visit-message
          :joker-visit="jokerVisit"
          :group-id="groupId"
        ></joker-visit-message>
      </template>
      <template #custom-action-icon>
        <o-icon icon="subway"></o-icon>
      </template>
    </group-chat>
  </div>
  <visit-modal
    v-if="groupId"
    v-model:active="modalOpen"
    :group-id="groupId"
  ></visit-modal>
</template>

<script>
import GroupChat from '@/components/GroupChat'
import { useUserSession } from '@/stores/userSession'
import { useOperator } from '@/composables/useOperator'
import StationVisitMessage from '@/components/StationVisitMessage'
import { useStations } from '@/stores/stations'
import { supabase } from '@/client'
import { showAlert } from '@/utils'
import slugify from 'slugify'
import { useGroup } from '@/stores/groups'
import { useGroupScores } from '@/stores/groupScores'
import { useChatContents } from '@/stores/chatContent'
import { useJokers } from '@/stores/jokers'
import JokerVisitMessage from '@/components/JokerVisitMessage'
import VisitModal from '@/components/VisitModal'

export default {
  name: 'ChatView',
  components: { VisitModal, JokerVisitMessage, StationVisitMessage, GroupChat },
  props: {
    groupId: { type: Number, required: true },
  },
  data() {
    const userSessionStore = useUserSession()
    const chatContentsStore = useChatContents(this.groupId)
    chatContentsStore.subscribe()

    return {
      modalOpen: false,
      chatTop: 0,
      stop: null,
      fileLabel: '',
      photo: null,
      operatorName: useOperator(this.groupId).operatorName,
      userId: userSessionStore.userId,
      userName: userSessionStore.user?.scoutName,
      groupScoresStore: useGroupScores(),
      chatContentsStore,
      allChatContentLoaded: false,
      fakeMessages: null,
    }
  },
  computed: {
    station() {
      let match
      if (!this.stop || !(match = this.stop.match(/^station-([0-9]+)$/))) {
        return null
      }
      return this.stations.find((station) => station.id === parseInt(match[1]))
    },
    joker() {
      let match
      if (!this.stop || !(match = this.stop.match(/^joker-([0-9]+)$/))) {
        return null
      }
      return this.jokers.find((joker) => joker.id === parseInt(match[1]))
    },
    stations() {
      const stationsStore = useStations()
      stationsStore.fetch()
      return stationsStore.all
    },
    jokers() {
      const jokersStore = useJokers()
      jokersStore.subscribe()
      return jokersStore.all
    },
    stationsAndJokers() {
      return this.stations
        .map((station) => ({ ...station, type: 'station' }))
        .concat(this.jokers.map((joker) => ({ ...joker, type: 'joker' })))
        .sort((a, b) => a.name.localeCompare(b.name))
    },
    stationVisits() {
      return this.chatContentsStore.allStationVisits
    },
    jokerVisits() {
      return this.chatContentsStore.allJokerVisits
    },
    allChatContent() {
      return this.chatContentsStore.all
    },
    balance() {
      return this.groupScoresStore.balances[this.groupId] + '.-'
    },
  },
  async mounted() {
    if (this.$refs.top) {
      this.chatTop = Math.ceil(this.$refs.top.getBoundingClientRect().bottom)
    }
    if (this.$route.query.action === 'visit') {
      this.modalOpen = true
    }
  },
  methods: {
    async fetchMoreChatContent() {
      const moreToLoad = await this.chatContentsStore.fetchMore()
      if (moreToLoad !== undefined) {
        this.allChatContentLoaded = !moreToLoad
      }
    },
    onChangeStop() {
      const responses = [
        'Nie! Zeig Fotti!',
        'Eh nöd! Chaschs bewise?',
        'Nice! Wie gsehts deet us?',
        "Pics or it didn't happen!",
        'Ja was! Zeig..?',
      ]
      this.fileLabel = responses[Math.floor(Math.random() * responses.length)]
    },
    groupHasLessMoneyThan(stationOrJoker) {
      return (
        stationOrJoker.type === 'station' &&
        stationOrJoker.value > this.groupScoresStore.balances[this.groupId]
      )
    },
    async submit() {
      const timestamp = new Date().toISOString()
      const stopName = this.station?.name || this.joker?.name || this.stop
      const groupName = useGroup(this.groupId).entry?.name || this.groupId
      const extension = this.photo.name.split('.').pop()
      const filename = slugify(
        `${timestamp}-${stopName}-${groupName}`
      ).substring(0, 62 - extension.length)
      const { data, error: err } = await supabase.storage
        .from('proofPhotos')
        .upload(`${filename}.${extension}`, this.photo)
      if (err) {
        console.log(err)
        showAlert(
          'Öppis isch schiäf gangä. Probiär mal d Sitä neu z ladä und dä Bsuäch nomal z erfassä.'
        )
        return
      }
      await (this.station
        ? this.submitStationVisit(data.path)
        : this.submitJokerVisit(data.path))
      this.stop = null
      this.photo = null
      this.modalOpen = false
    },
    async submitStationVisit(proofPhotoPath) {
      const { error } = await supabase.rpc('visit_station', {
        station_id: this.station.id,
        proof_photo_path: proofPhotoPath,
      })
      if (error) {
        console.log(error)
        showAlert(
          'Öppis isch schiäf gangä. Probiär mal d Sitä neu z ladä und dä Stationsbsuäch nomal z erfassä.'
        )
      }
    },
    async submitJokerVisit(proofPhotoPath) {
      const { error } = await supabase.rpc('visit_joker', {
        joker_id: this.joker.id,
        proof_photo_path: proofPhotoPath,
      })
      if (error) {
        console.log(error)
        showAlert(
          'Öppis isch schiäf gangä. Probiär mal d Sitä neu z ladä und dä Jokärbsuäch nomal z erfassä.'
        )
      }
    },
  },
}
</script>
