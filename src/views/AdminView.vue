<template>
  <div class="column is-full has-text-centered">
    <active-operator-call-card></active-operator-call-card>
    <div class="card has-text-left">
      <header class="card-header has-background-light">
        <span class="card-header-title title is-4">⚙️ Iistelligä</span>
      </header>
      <div class="card-content">
        <div class="columns">
          <div class="column">
            <o-field grouped group-multiline>
              <o-field label="Start">
                <o-datetimepicker
                  v-model="gameStart"
                  icon="calendar"
                  expanded
                  locale="de-CH"
                  :timepicker="{ hourFormat: '24' }"
                >
                </o-datetimepicker>
                <p class="control">
                  <button
                    @click="setStartTimeToNow"
                    class="button is-info is-outlined"
                  >
                    Spiel startä (Startzit uf jetzt setzä)
                  </button>
                </p>
              </o-field>
              <o-field label="Ändi">
                <o-datetimepicker
                  v-model="gameEnd"
                  icon="calendar"
                  expanded
                  locale="de-CH"
                  :timepicker="{ hourFormat: '24' }"
                >
                </o-datetimepicker>
                <p class="control">
                  <button
                    @click="setEndTimeToNow"
                    class="button is-info is-outlined"
                  >
                    Spiel beändä (Endzit uf jetzt setzä)
                  </button>
                </p>
              </o-field>
            </o-field>
            <o-field grouped group-multiline>
              <form @submit.prevent="changeMap">
                <o-field label="Chartä">
                  <o-upload v-model="mapFile" capture accept="image/*">
                    <o-button tag="a" variant="secondary">
                      <o-icon icon="map"></o-icon>
                      <span>Neui Chartä ufäladä</span>
                    </o-button>
                  </o-upload>
                </o-field>
                <o-button
                  variant="primary"
                  native-type="submit"
                  outlined
                  :disabled="!mapFile"
                >
                  Let's go!
                </o-button>
              </form>
            </o-field>
          </div>
          <div class="column">
            <p class="title is-6">{{ timeSinceLastActiveMrTChange }}</p>
            <p class="title is-6">{{ timeSinceLastMrTReport }}</p>
            <o-field grouped>
              <p class="control" v-if="currentMrT && !mrTShouldCallOperator">
                <button class="button is-link is-warning" @click="promptMrT">
                  Gruppä zum Aruäf uffordärä
                </button>
              </p>
              <p class="control" v-if="currentMrTActive">
                <button class="button is-link is-danger" @click="confiscateMrT">
                  Mr T. beschlagnahmä
                </button>
              </p>
              <p class="control" v-else>
                <button
                  class="button is-link is-warning is-outlined"
                  @click="releaseMrT"
                >
                  Mr T. hät sich gmäldät, wieder freigä
                </button>
              </p>
            </o-field>
            <hr />
            <header class="title is-4">Nachricht a alli</header>
            <form @submit.prevent="setMessage">
              <o-field grouped group-multiline>
                <o-field>
                  <o-select name="type" v-model="selectedMessageType">
                    <option value="info">blau</option>
                    <option value="success">grüän</option>
                    <option value="warning">gääl</option>
                    <option value="danger">rot</option>
                    <option value="dark">schwarz</option>
                  </o-select>
                </o-field>
                <o-field>
                  <o-input
                    type="text"
                    v-model="selectedMessageTitle"
                    name="title"
                    placeholder="Titäl"
                  >
                  </o-input>
                </o-field>
                <o-field>
                  <button
                    type="submit"
                    :class="'button is-' + selectedMessageType"
                  >
                    Speichärä
                  </button>
                </o-field>
              </o-field>
              <o-field>
                <o-input
                  type="textarea"
                  v-model="selectedMessageText"
                  name="message"
                >
                </o-input>
              </o-field>
            </form>
          </div>
        </div>
        <div class="columns">
          <div
            class="column is-full is-one-third-desktop is-offset-one-third-desktop"
          >
            <global-message></global-message>
          </div>
        </div>
      </div>
    </div>
    <abteilung-management></abteilung-management>
    <group-management></group-management>
    <user-management></user-management>
    <mock-data-creator v-if="dev"></mock-data-creator>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useUserSession } from '@/stores/userSession'
import { storeToRefs } from 'pinia'
import { useRouter } from 'vue-router'
import ActiveOperatorCallCard from '@/components/ActiveOperatorCallCard'
import { useEditableSettings } from '@/composables/editableSettings'
import UserManagement from '@/components/UserManagement'
import GroupManagement from '@/components/GroupManagement'
import AbteilungManagement from '@/components/AbteilungManagement'
import MockDataCreator from '@/components/MockDataCreator'
import { useCurrentMrT } from '@/composables/useCurrentMrT'
import { supabase } from '@/client.js'
import { showAlert } from '@/utils.js'
import slugify from 'slugify'
import useGlobalMessage from '@/composables/useGlobalMessage.js'
import GlobalMessage from '@/components/GlobalMessage.vue'

const userSession = useUserSession()
const { isAdmin } = storeToRefs(userSession)

if (!isAdmin.value) {
  const router = useRouter()
  router.replace({ name: 'dashboard' })
}

const {
  gameStart,
  gameEnd,
  setStartTimeToNow,
  setEndTimeToNow,
  setMapUrl,
  setGlobalMessage,
} = useEditableSettings()

const dev = import.meta.env.DEV

const {
  currentMrT,
  currentMrTActive,
  mrTShouldCallOperator,
  timeSinceLastActiveMrTChange,
  timeSinceLastMrTReport,
  promptMrT,
  confiscateMrT,
  releaseMrT,
} = useCurrentMrT()

const mapFile = ref(null)
async function changeMap() {
  if (!mapFile.value) return

  const extension = mapFile.value.name.split('.').pop()
  const filename = slugify(crypto.randomUUID() + '-map').substring(
    0,
    62 - extension.length
  )
  const { data, error } = await supabase.storage
    .from('abteilungLogos')
    .upload(`${filename}.${extension}`, mapFile.value)
  if (error) {
    console.log(error)
    showAlert(
      'Öppis isch schiäf gangä. Probiär mal d Sitä neu z ladä und d Chartä nomal ufäzladä.'
    )
    return
  }
  const {
    data: { publicUrl },
  } = supabase.storage.from('abteilungLogos').getPublicUrl(data.path)

  const result = await setMapUrl(publicUrl)
  if (result.error) {
    console.log(result.error)
    showAlert(
      'Öppis isch schiäf gangä. Probiär mal d Sitä neu z ladä und d Chartä nomal ufäzladä.'
    )
  }
  mapFile.value = null
}

const { messageTitle, messageText, messageType } = useGlobalMessage()
const selectedMessageTitle = ref(messageTitle.value)
const selectedMessageText = ref(messageText.value)
const selectedMessageType = ref(messageType.value)
function setMessage() {
  setGlobalMessage({
    messageTitle: selectedMessageTitle.value,
    messageText: selectedMessageText.value,
    messageType: selectedMessageType.value,
  })
}
</script>

<script>
export default {
  name: 'AdminView',
}
</script>
