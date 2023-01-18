<template>
  <message-box :type="messageType">
    <template v-if="isOwnGroup">
      <template v-if="isAccepted">
        <template v-if="needsVerification">
          <div class="is-size-5 has-text-weight-semibold">
            {{ visitorGroupName }} isch bi {{ visitedStationName }} gsi. D
            Zentralä muäs grad no schnäll berächnä ob zu däm Ziitpunkt gnuäg
            Cäsh umä gsii isch zums chaufä 🏦
            <span class="checking-spinner">
              <o-loading
                :full-page="false"
                v-model:active="alwaysSpinning"
                overlayClass="no-overlay"
                :can-cancel="false"
              ></o-loading>
            </span>
          </div>
          <div class="is-size-6 is-multiline-text">
            {{ stationVisit.operatorComment }}
          </div>
        </template>
        <template v-else-if="isInvalid">
          <div class="is-size-5 has-text-weight-semibold">
            {{ visitorGroupName }} isch bi {{ visitedStationName }} gsi, aber
            miär händ läidär nöd gnuäg Cäsh gha zums chaufä 💔
          </div>
          <div class="is-size-6 is-multiline-text">
            {{ stationVisit.operatorComment }}
          </div>
        </template>
        <template v-else>
          <template v-if="isPurchase">
            <div class="is-size-5 has-text-weight-semibold">
              {{ visitorGroupName }} isch bi {{ visitedStationName }} gsi und
              häts gchauft 💳
              <span v-if="interestPerMinute" class="tag is-info is-small mb-2"
                >+{{ interestPerMinute }}.-/min</span
              >
            </div>
            <div class="is-size-6 is-multiline-text">
              {{ stationVisit.operatorComment }}
            </div>
          </template>
          <template v-else>
            <div class="is-size-5 has-text-weight-semibold">
              {{ visitorGroupName }} isch bi {{ visitedStationName }} gsi, aber
              die Station ghört scho {{ stationOwnerName }}. Darum hämmer müäsä
              {{ rentAmount }} Miäti zahlä 💸
            </div>
            <div class="is-size-6 is-multiline-text">
              {{ stationVisit.operatorComment }}
            </div>
          </template>
        </template>
      </template>
      <template v-else-if="isRejected">
        <div class="is-size-5 has-text-weight-semibold">
          {{ visitorGroupName }} hät behauptät, dass sie bi
          {{ visitedStationName }} gsi sind, aber d Zentralä hät das abglehnt 🙅
        </div>
        <div class="is-size-6 is-multiline-text">
          {{ stationVisit.operatorComment }}
        </div>
      </template>
      <template v-else>
        <div class="is-size-5 has-text-weight-semibold">
          {{ visitorGroupName }} isch bi {{ visitedStationName }} gsi. D
          Zentralä überprüäft das grad no 🕵️
          <span class="checking-spinner">
            <o-loading
              :full-page="false"
              v-model:active="alwaysSpinning"
              overlayClass="no-overlay"
              :can-cancel="false"
            ></o-loading>
          </span>
        </div>
        <div class="is-size-6 is-multiline-text">
          {{ stationVisit.operatorComment }}
        </div>
      </template>
    </template>
    <template v-else>
      <template v-if="isPurchase">
        <div class="is-size-5 has-text-weight-semibold">
          {{ visitorGroupName }} isch vor ois bi {{ visitedStationName }} gsi
          und häts gchauft 💰💰💰
        </div>
      </template>
      <template v-else>
        <div class="is-size-5 has-text-weight-semibold">
          {{ visitorGroupName }} isch bi {{ visitedStationName }} gsi und hät
          ois {{ rentAmount }} Miäti zahlt 🤑
        </div>
      </template>
    </template>
    <div v-if="stationVisit.proofPhotoUrl">
      <a v-if="isOwnGroup" :href="stationVisit.proofPhotoUrl" target="_blank">
        <span
          class="station-visit-image"
          :style="{
            backgroundImage: `url('${stationVisit.proofPhotoPreviewUrl}')`,
          }"
        ></span
      ></a>
      <span
        v-else
        class="station-visit-image"
        :style="{
          backgroundImage: `url('${stationVisit.proofPhotoPreviewUrl}')`,
        }"
      ></span>
    </div>
    <div class="vac-text-timestamp">
      <span>{{ stationVisit.createdAt?.toLocaleString() }}</span>
    </div>
  </message-box>
</template>

<script>
import { useStationVisits } from '@/stores/stationVisits'
import { useSettings } from '@/stores/settings'
import MessageBox from '@/components/MessageBox'

export default {
  name: 'StationVisitMessage',
  components: { MessageBox },
  props: {
    stationVisit: { type: Object, required: true },
    groupId: { type: Number, required: true },
  },
  data: () => ({
    alwaysSpinning: true,
  }),
  computed: {
    isOwnGroup() {
      return this.stationVisit.groupId === this.groupId
    },
    isAccepted() {
      return !!this.stationVisit.acceptedAt
    },
    isRejected() {
      return !!this.stationVisit.rejectedAt
    },
    needsVerification() {
      return this.stationVisit.needsVerification
    },
    isInvalid() {
      return !this.needsVerification && !this.stationVisit.verifiedAt
    },
    isPurchase() {
      const { loading, all } = useStationVisits()
      return (
        !loading &&
        all
          .slice()
          .sort((a, b) => a.createdAt - b.createdAt)
          .find(
            (sv) =>
              sv.stationId === this.stationVisit.stationId &&
              sv.acceptedAt &&
              !sv.rejectedAt &&
              !sv.needsVerification &&
              sv.verifiedAt
          )?.id === this.stationVisit.id
      )
    },
    stationOwnerName() {
      return this.isPurchase
        ? this.stationVisit.station?.group?.name || 'oisärä Gruppä'
        : 'ärä andärä Gruppä'
    },
    visitorGroupName() {
      return this.isOwnGroup
        ? this.stationVisit.group?.name || 'Ä unbekannti Gruppä'
        : 'Ä andäri Gruppä'
    },
    visitedStationName() {
      return this.stationVisit.station?.name || 'ärä unbekanntä Station'
    },
    interestRatePerMinute() {
      const { loading, entry: settings } = useSettings()
      if (loading || !this.isPurchase || !this.isOwnGroup) return null

      const buyingTime = this.stationVisit.createdAt
      const lerpVal =
        (buyingTime - settings.gameStart) /
        (settings.gameEnd - settings.gameStart)
      const interpolated =
        settings.interestRateStart +
        lerpVal * (settings.interestRateEnd - settings.interestRateStart)
      return interpolated / settings.interestPeriod
    },
    interestPerMinute() {
      if (!this.interestRatePerMinute || !this.stationVisit.station?.value)
        return null
      return Math.round(
        this.stationVisit.station?.value * this.interestRatePerMinute
      )
    },
    rentAmount() {
      const { loading, entry: settings } = useSettings()
      if (loading || !this.stationVisit.station) return 'än unbekanntä Betrag'
      return this.stationVisit.station?.value * settings.rentRatio + '.-'
    },
    messageType() {
      return this.isOwnGroup
        ? this.isAccepted
          ? this.needsVerification
            ? 'info'
            : this.isInvalid
            ? 'danger'
            : this.isPurchase
            ? 'success'
            : 'warning'
          : this.isRejected
          ? 'danger'
          : 'primary'
        : this.isPurchase
        ? 'dark'
        : 'success'
    },
  },
}
</script>

<style scoped></style>
