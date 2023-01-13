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
      stations: [
        // TODO
        { id: 1, name: 'HB', value: 5000 },
        { id: 2, name: 'Paradeplatz', value: 7000 },
      ],
      messages: [], // TODO useMessages(this.groupId).all
      stationVisits: [], // TODO useStationVisits(this.groupId).all
      operatorName: useOperator(this.groupId).operatorName,
      userId: useUserSession().userId,
    }
  },
  computed: {
    presentedMessages() {
      return this.messages.map((message) => ({
        ...message,
        _id: message.id,
        senderId: message.sender_id,
        timestamp: message.created_at.toString().substring(16, 21),
        date: message.created_at.toDateString(),
      }))
    },
    presentedStationVisits() {
      return this.stationVisits.map((sv) => {
        return {
          ...sv,
          _id: sv.id,
          senderId: this.userId,
          content: '',
          timestamp: sv.created_at.toString().substring(16, 21),
          date: sv.created_at.toDateString(),
        }
      })
    },
    allChatContent() {
      return this.presentedMessages
        .concat(this.presentedStationVisits)
        .sort((a, b) => a.created_at - b.created_at)
    },
  },
  mounted() {
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
      return { id: message._id, sender_id: message.senderId, ...message }
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
    submit() {
      console.log(this.photo)
      this.stationVisits.push({
        id: crypto.randomUUID(),
        created_at: new Date(),
      })
      this.station = null
      this.photo = null
      this.modalOpen = false
    },
  },
}
</script>
