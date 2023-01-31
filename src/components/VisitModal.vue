<template>
  <o-modal v-bind="$attrs">
    <div class="card modal-card">
      <o-loading :active="loading"></o-loading>
      <div class="card-content">
        <form @submit.prevent="submit">
          <o-field label="Guäthabä">
            <o-input
              :model-value="balance"
              class="has-text-weight-semibold"
              expanded
              disabled
            ></o-input>
          </o-field>
          <o-field label="Wo sinder grad?">
            <o-select v-model="stop" expanded required @input="onChangeStop">
              <option
                v-for="stop in stationsAndJokers"
                :value="`${stop.type}-${stop.id}`"
                :key="`${stop.type}-${stop.id}`"
                :disabled="groupHasLessMoneyThan(stop)"
              >
                <template v-if="groupHasLessMoneyThan(stop)">
                  🚫 {{ stop.name }} - {{ stop.value }}.- (nöd gnuäg Cäsh)
                </template>
                <template v-else-if="stop.type === 'joker'">
                  🃏 {{ stop.name }} (Jokär) - {{ stop.value }}.-
                  <template v-if="stop.bonusCallValue"
                    >(+{{ stop.bonusCallValue }}.- Bonus-Aruäf)</template
                  >
                </template>
                <template v-else>
                  {{ stop.name }} - {{ stop.value }}.-
                </template>
              </option>
            </o-select>
          </o-field>
          <o-field v-if="station" :label="fileLabel">
            <o-upload
              v-model="photo"
              capture
              accept="image/*, video/*"
              required
            >
              <o-button tag="a" variant="secondary">
                <o-icon icon="camera"></o-icon>
                <span>Lug, da!</span>
              </o-button>
            </o-upload>
          </o-field>
          <o-button
            v-if="station && photo"
            variant="primary"
            native-type="submit"
            outlined
          >
            Geilo, probieremer z chaufä!
          </o-button>
          <o-field v-if="joker">
            <template #label>
              <template v-if="joker.challenge">
                <div>
                  Ah ächt? Dänn müändär aber zum Bewiis ä Challenge erfüllä:
                </div>
                <div class="has-text-primary is-size-3">
                  {{ joker.challenge }}
                </div>
              </template>
              <template v-else>{{ fileLabel }}</template>
            </template>
            <o-upload
              v-model="photo"
              capture
              accept="image/*, video/*"
              required
            >
              <o-button tag="a" variant="secondary">
                <o-icon icon="camera"></o-icon>
                <span>Lug, da!</span>
              </o-button>
            </o-upload>
          </o-field>
          <o-button
            v-if="joker && photo"
            variant="primary"
            native-type="submit"
            outlined
          >
            Let's goooo!
          </o-button>
        </form>
      </div>
    </div>
  </o-modal>
</template>

<script>
import { useStations } from '@/stores/stations'
import { supabase } from '@/client'
import { showAlert } from '@/utils'
import slugify from 'slugify'
import { useGroup } from '@/stores/groups'
import { useGroupScores } from '@/stores/groupScores'
import { useJokers } from '@/stores/jokers'

export default {
  name: 'VisitModal',
  props: {
    groupId: { type: Number, required: true },
  },
  data() {
    return {
      loading: true,
      stop: null,
      fileLabel: '',
      photo: null,
      groupScoresStore: useGroupScores(),
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
    balance() {
      return this.groupScoresStore.balances[this.groupId] + '.-'
    },
  },
  mounted() {
    this.groupScoresStore.fetch(true, () => {
      this.loading = false
    })
  },
  methods: {
    onChangeStop() {
      const responses = [
        'Fett!',
        'Als ob!',
        'Geiääl!!!',
        'Unmöglich!',
        '🤯😳😊👍👍👌',
        'Schön wärs!',
        'Wärs glaubt.',
        'Yeah, right.',
        'Dude! No way!',
        'Ja was! Zäig..?',
        'Niä! Zäig Fotti!',
        'So en Lügäbüütel...',
        'Sheesh Bruder, ächt?',
        'Dayum! Häsch es Fotti?',
        'Eh nöd! Chaschs bewisä?',
        'Das cha doch nöd sii..?',
        'Und das sölli der abnää?',
        'Nice! Wiä gsehts det us?',
        "Pics or it didn't happen!",
        'Alter episch. Häsch Bewiis?',
        'Verarschä chani mi au sälber.',
        'Ja genau, huärä sindär deet...',
        'Ehrämaa. Häsch äs Bild gmacht?',
        'Ja schön wärs, das glaubi nöd.',
        'Schiibäts? Und das sölli glaubä?',
        'Alter Falter, Gönnung. Häsch Pics?',
        'Bro wie machäd iär das? Scho deet?',
        'Läuft bei euch. Chamär das au aluägä?',
        'Wottsch mi nüsslä? Das stimmt doch nöd.',
        'Bra iär sind ja huärä schnäll. Zäig mal?',
        'Legändä! Nur no schnäll en Bewiis ufäladä',
        'Chillig. Chasch das au dä Zentralä bewiisä?',
        'Gönnäd oi. Also sindär sichär am richtigä Ort?',
        'OMG slayyy!! Abär d Zentralä glaubt der doch das nöd...',
        'Am riissä! Grad än Bewiis inäfätzä, dänn chunt dä Cashflow.',
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
      this.$emit('update:active', false)
    },
    async submitStationVisit(proofPhotoPath) {
      const { error } = await supabase.rpc('visit_station', {
        station_id: this.station.id,
        proof_photo_path: proofPhotoPath,
        group_id: this.groupId,
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
        group_id: this.groupId,
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
