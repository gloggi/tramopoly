<template>
  <div ref="top" style="width: 100%; height: 0" />
  <div class="fullscreen-chat" :style="{ top: chatTop + 'px' }">
    <group-chat
      :group-id="groupId"
      :messages="allChatContent"
      init-message="Willkommä bim Tramopoly-Chät 💬 Da chasch mit de Zentralä kommuniziärä. Mit äm Tram-Chnopf chasch Stationä und Jokärs bsuächä ↴"
      single-room
      @add-message="addMessage"
      @textarea-action-handler="openModal"
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
import { useMessages } from '@/stores/messages'
import { useGroupBalances } from '@/stores/groupBalances'

export default {
  name: 'ChatView',
  components: { StationVisitMessage, GroupChat },
  props: {
    groupId: { type: Number, required: true },
  },
  data() {
    const userSessionStore = useUserSession()
    return {
      modalOpen: false,
      chatTop: 0,
      station: null,
      fileLabel: '',
      photo: null,
      operatorName: useOperator(this.groupId).operatorName,
      userId: userSessionStore.userId,
      userName: userSessionStore.user?.scoutName,
      groupBalancesStore: useGroupBalances(),
    }
  },
  computed: {
    messages() {
      const messagesStore = useMessages({
        select:
          '*,message_files(*),sender:sender_id(*),reply_message:reply_message_id(*,message_files(*),sender:sender_id(*))',
        filter: { group_id: this.groupId },
      })
      messagesStore.subscribe()
      return messagesStore.all
    },
    stations() {
      const stationsStore = useStations()
      stationsStore.fetch()
      return stationsStore.all
    },
    stationVisits() {
      const stationVisitsStore = useStationVisits({
        select: '*,group:group_id(*),station:station_id(*)',
        filter: { group_id: this.groupId },
      })
      stationVisitsStore.subscribe()
      return stationVisitsStore.all
    },
    allChatContent() {
      return this.messages
        .map((message) => message.toChatFormat())
        .concat(this.stationVisits.map((sv) => sv.toChatFormat()))
        .sort((a, b) => a.createdAt - b.createdAt)
    },
  },
  async mounted() {
    if (this.$refs.top) {
      this.chatTop = Math.ceil(this.$refs.top.getBoundingClientRect().bottom)
    }
    if (this.$route.query.action === 'visitStation') {
      this.openModal()
    }
  },
  methods: {
    async addMessage(message) {
      try {
        const uploadedFiles = await Promise.all(
          (message.files || []).map(async (file) => {
            const timestamp = new Date().toISOString()
            const groupName = useGroup(this.groupId).entry?.name || this.groupId
            const extension = file.extension
            const filename = slugify(
              `${timestamp}-${groupName}-${this.userName}}`
            ).substring(0, 62 - extension.length)
            const { data, error } = await supabase.storage
              .from('messageFiles')
              .upload(
                `${filename}.${extension}`,
                await (await fetch(file.url)).blob(),
                { contentType: file.type }
              )
            if (error) throw error
            return data.path
          })
        )
        const { error } = await supabase.rpc('post_message', {
          content: message.content,
          file_paths: uploadedFiles,
          reply_message_id: message.replyMessage?._id || null,
        })
        if (error) throw error
      } catch (error) {
        console.log(error)
        showAlert(
          'Öppis isch schiäf gangä. Probiär mal d Siitä neu z ladä und dä Stationsbsuäch nomal z erfassä.'
        )
      }
    },
    async openModal() {
      this.groupBalancesStore.fetch(true, () => {
        this.modalOpen = true
      })
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
      return cost > this.groupBalancesStore.balances[this.groupId]
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
