<template>
  <div ref="top" style="width: 100%; height: 0" />
  <div class="fullscreen-chat" :style="{ top: chatTop + 'px' }">
    <group-chat
      :group-id="groupId"
      :messages="allChatContent"
      init-message="Willkommä bim Tramopoly-Chät 💬 Da chasch mit de Zentralä kommuniziärä. Mit äm Tram-Chnopf chasch Stationä und Jokärs bsuächä ↴"
      single-room
      @add-message="addMessage"
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
        ></station-visit-message>
      </template>
      <template #custom-action-icon>
        <o-icon icon="subway"></o-icon>
      </template>
    </group-chat>
  </div>
  <o-modal v-model:active="modalOpen">
    <div class="card modal-card">
      <div class="card-content">
        <form @submit.prevent="submit">
          <o-field label="Wo sinder grad?">
            <o-select
              v-model="station"
              expanded
              required
              @input="onChangeStation"
            >
              <option
                v-for="station in stations"
                :value="station.id"
                :key="station.id"
                :disabled="groupHasLessMoneyThan(station.value)"
              >
                <template v-if="groupHasLessMoneyThan(station.value)"
                  >🚫 {{ station.name }} - {{ station.value }} (nöd gnuäg
                  Cäsh)</template
                >
                <template v-else
                  >{{ station.name }} - {{ station.value }}</template
                >
              </option>
            </o-select>
          </o-field>
          <o-field v-show="station" :label="fileLabel">
            <o-upload v-model="photo" capture accept="image/*" required>
              <o-button tag="a" variant="secondary">
                <o-icon icon="camera"></o-icon>
                <span>Lug, da!</span>
              </o-button>
            </o-upload>
          </o-field>
          <o-button v-if="photo" variant="primary" native-type="submit" outlined
            >Geilo, probieremer z chaufä!</o-button
          >
        </form>
      </div>
    </div>
  </o-modal>
</template>

<script>
import GroupChat from '@/components/GroupChat'
import { useUserSession } from '@/stores/userSession'
import { useOperator } from '@/composables/useOperator'
import StationVisitMessage from '@/components/StationVisitMessage'
import { useStations } from '@/stores/stations'
import { supabase } from '@/client'
import { showAlert } from '@/utils'
import { useStationVisits } from '@/stores/stationVisits'
import slugify from 'slugify'
import { useGroup } from '@/stores/groups'

export default {
  name: 'ChatView',
  components: { StationVisitMessage, GroupChat },
  props: {
    groupId: { type: Number, required: true },
  },
  data() {
    return {
      modalOpen: false,
      chatTop: 0,
      station: null,
      fileLabel: '',
      photo: null,
      messages: [], // TODO useMessages(this.groupId).all
      operatorName: useOperator(this.groupId).operatorName,
      userId: useUserSession().userId,
    }
  },
  computed: {
    stations() {
      const stationsStore = useStations()
      stationsStore.fetch()
      return stationsStore.all
    },
    stationVisits() {
      const stationVisitsStore = useStationVisits({
        filter: { group_id: this.groupId },
      })
      stationVisitsStore.subscribe()
      return stationVisitsStore.all
    },
    presentedMessages() {
      return this.messages.map((message) => ({
        ...message,
        _id: message.id,
        senderId: message.sender_id,
        timestamp: message.createdAt.toString().substring(16, 21),
        date: message.createdAt.toDateString(),
      }))
    },
    allChatContent() {
      return this.presentedMessages
        .concat(this.stationVisits.map((sv) => sv.toMessage()))
        .sort((a, b) => a.createdAt - b.createdAt)
    },
  },
  async mounted() {
    if (this.$refs.top) {
      this.chatTop = Math.ceil(this.$refs.top.getBoundingClientRect().bottom)
    }
    if (this.$route.query.action === 'visitStation') {
      this.modalOpen = true
    }
  },
  methods: {
    addMessage(message) {
      this.messages.push(this.prepareMessageForStorage(message))
    },
    prepareMessageForStorage(message) {
      return {
        id: message._id,
        sender_id: message.senderId,
        createdAt: new Date(message.created_at),
        ...message,
      }
    },
    onChangeStation() {
      const responses = [
        'Nie! Zeig Fotti!',
        'Eh nöd! Chaschs bewiise?',
        'Nice! Wie gsehts deet us?',
        "Pics or it didn't happen!",
      ]
      this.fileLabel = responses[Math.floor(Math.random() * responses.length)]
    },
    groupHasLessMoneyThan(cost) {
      // TODO
      return cost > 6000
    },
    async submit() {
      const timestamp = new Date().toISOString()
      const stationName =
        this.stations.find((station) => station.id === this.station).name ||
        this.station
      const groupName = useGroup(this.groupId).entry?.name || this.groupId
      const extension = this.photo.name.split('.').pop()
      const filename = slugify(
        `${timestamp}-${stationName}-${groupName}}`
      ).substring(0, 62 - extension.length)
      const { data, error: err } = await supabase.storage
        .from('proofPhotos')
        .upload(`${filename}.${extension}`, this.photo)
      if (err) {
        console.log(error)
        showAlert(
          'Öppis isch schiäf gangä. Probiär mal d Siitä neu z ladä und dä Stationsbsuäch nomal z erfassä.'
        )
        return
      }
      const { error } = await supabase.rpc('visit_station', {
        station_id: this.station,
        proof_photo_path: data.path,
      })
      if (error) {
        console.log(error)
        showAlert(
          'Öppis isch schiäf gangä. Probiär mal d Siitä neu z ladä und dä Stationsbsuäch nomal z erfassä.'
        )
      }
      this.station = null
      this.photo = null
      this.modalOpen = false
    },
  },
}
</script>
