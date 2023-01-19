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
                    Spiel startä (Startziit uf jetzt setzä)
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
                    Spiel beändä (Endziit uf jetzt setzä)
                  </button>
                </p>
              </o-field>
            </o-field>
          </div>
          <div class="column">
            <h5 class="title is-6">{{ minutesSinceLastActiveMrTChange }}</h5>
            <o-field grouped>
              <p
                class="control"
                v-if="mrTChanges && mrTChanges.length && !mrTShouldCallOperator"
              >
                <button
                  class="button is-link is-warning"
                  @click="() => promptMrT(currentMrT)"
                >
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
                  Mr T. hät sich gmäldät
                </button>
              </p>
            </o-field>
            <template v-if="message">
              <hr />
              <header class="title is-4">Nachricht a alli</header>
              <form @submit.prevent="setMessage">
                <o-field grouped group-multiline>
                  <o-field>
                    <o-select name="type" v-model="selectedMessageType">
                      <option value="is-info">blau</option>
                      <option value="is-success">grüän</option>
                      <option value="is-warning">gääl</option>
                      <option value="is-danger">rot</option>
                      <option value="is-dark">schwarz</option>
                    </o-select>
                  </o-field>
                  <o-field>
                    <o-input
                      type="text"
                      :value="message.title"
                      name="title"
                      placeholder="Titäl"
                    >
                    </o-input>
                  </o-field>
                  <o-field>
                    <button
                      type="submit"
                      :class="'button ' + selectedMessageType"
                    >
                      Speichärä
                    </button>
                  </o-field>
                </o-field>
                <o-field>
                  <o-input
                    type="textarea"
                    :value="message.message"
                    name="message"
                  >
                  </o-input>
                </o-field>
              </form>
            </template>
          </div>
        </div>
        <div class="columns">
          <div
            class="column is-full is-one-third-desktop is-offset-one-third-desktop"
          >
            <slot name="message"></slot>
          </div>
        </div>
      </div>
    </div>
    <abteilung-management></abteilung-management>
    <group-management></group-management>
    <user-management></user-management>
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

const userSession = useUserSession()
const { isAdmin } = storeToRefs(userSession)

if (!isAdmin.value) {
  const router = useRouter()
  router.replace({ name: 'dashboard' })
}

const selectedMessageType = ref('is-info')

const { gameStart, gameEnd, setStartTimeToNow, setEndTimeToNow } =
  useEditableSettings()

// TODO
const mrTChanges = []
const message = ''
const currentMrT = null
const currentMrTActive = false
const mrTShouldCallOperator = true
const minutesSinceLastActiveMrTChange = 0
const setMessage = () => {}
const promptMrT = () => {}
const confiscateMrT = () => {}
const releaseMrT = () => {}
</script>

<script>
export default {
  name: 'AdminView',
}
</script>
