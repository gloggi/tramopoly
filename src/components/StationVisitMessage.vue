<template>
  <message-box :type="messageType">
    <template v-if="isOwnGroup">
      <template v-if="isAccepted">
        <template v-if="needsVerification">
          <div class="is-size-5 has-text-weight-semibold">
            {{ visitorGroupName }} isch bi {{ visitedStationName }} gsi. D
            Zentralä muäs grad no schnäll berächnä ob zu däm Zitpunkt gnuäg Cäsh
            umä gsi isch zums chaufä 🏦
            <span class="checking-spinner">
              <o-loading
                :full-page="false"
                v-model:active="alwaysSpinning"
                overlayClass="no-overlay"
                :can-cancel="false"
              ></o-loading>
            </span>
          </div>
        </template>
        <template v-else-if="isInvalid">
          <div class="is-size-5 has-text-weight-semibold">
            {{ visitorGroupName }} isch bi {{ visitedStationName }} gsi, aber
            miär händ läidär nöd gnuäg Cäsh gha zums chaufä 💔
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
          </template>
          <template v-else>
            <div class="is-size-5 has-text-weight-semibold">
              {{ visitorGroupName }} isch bi {{ visitedStationName }} gsi, aber
              die Station ghört scho {{ stationOwnerName }}. Darum hämmer müäsä
              {{ rentAmount }} Miäti zahlä 💸
            </div>
          </template>
        </template>
      </template>
      <template v-else-if="isRejected">
        <div class="is-size-5 has-text-weight-semibold">
          {{ visitorGroupName }} hät behauptät, dass sie bi
          {{ visitedStationName }} gsi sind, aber d Zentralä hät das abglehnt 🙅
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
    <div v-if="isOwnGroup && stationVisit.proofPhotoUrl">
      <a :href="stationVisit.proofPhotoUrl" target="_blank">
        <video
          v-if="isVideo"
          width="300"
          height="200"
          controls="controls"
          preload="none"
        >
          <source :src="stationVisit.proofPhotoUrl" />
          <a :href="stationVisit.proofPhotoUrl" target="_blank"
            >Video aazäigä</a
          >
        </video>
        <span
          v-else
          class="station-visit-image"
          :style="{
            backgroundImage: `url('${stationVisit.proofPhotoPreviewUrl}')`,
          }"
        ></span>
      </a>
    </div>
    <div class="is-size-6 is-multiline-text">
      {{ stationVisit.operatorComment }}
    </div>
    <div v-if="isOwnGroup && isOperator">
      <o-field addons root-class="is-justify-content-center">
        <o-button
          icon-left="check"
          variant="success"
          :outlined="!isAccepted"
          @click="rate('accepted')"
        >
          Akzeptiärt
        </o-button>
        <o-button
          icon-left="search"
          variant="dark"
          :outlined="isAccepted || isRejected"
          @click="rate(null)"
        >
          No unklar
        </o-button>
        <o-button
          icon-left="xmark"
          variant="danger"
          :outlined="!isRejected"
          @click="rate('rejected')"
        >
          Abglehnt
        </o-button>
        <comment-edit-modal
          table="station_visits"
          :id="stationVisit.id"
          :value="stationVisit.operatorComment"
        >
          Kommentiärä
        </comment-edit-modal>
      </o-field>
    </div>
    <div class="vac-text-timestamp">
      <span>{{ stationVisit.createdAt?.toLocaleString() }}</span>
    </div>
  </message-box>
</template>

<script>
import { useSettings } from '@/stores/settings'
import MessageBox from '@/components/MessageBox'
import { supabase } from '@/client'
import CommentEditModal from '@/components/CommentEditModal'

export default {
  name: 'StationVisitMessage',
  components: { CommentEditModal, MessageBox },
  props: {
    stationVisit: { type: Object, required: true },
    groupId: { type: Number, required: true },
    isOperator: { type: Boolean, default: false },
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
      return this.stationVisit.isPurchase
    },
    isVideo() {
      if (!this.stationVisit.proofPhotoUrl) return false
      return !!this.stationVisit._proofPhotoPath.match(
        /\.(mp4|mov|wmv|avi|webm|m4v|3gp|flv)$/i
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
            ? 'dark'
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
  mounted() {
    useSettings().subscribe()
  },
  methods: {
    async rate(rating) {
      await supabase.rpc('rate_station_visit', {
        station_visit_id: this.stationVisit.id,
        rating,
      })
    },
  },
}
</script>

<style scoped></style>
