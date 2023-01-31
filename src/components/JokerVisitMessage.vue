<template>
  <message-box :type="messageType">
    <template v-if="isAccepted">
      <div class="is-size-5 has-text-weight-semibold">
        {{ visitorGroupName }} isch bim Jokär {{ visitedJokerName }} gsi und hät
        {{ jokerVisit.joker.value }}.-<template
          v-if="jokerVisit.earnedBonusValue"
        >
          plus {{ jokerVisit.earnedBonusValue }}.- Bonus
        </template>
        iigsackt 💪
      </div>
    </template>
    <template v-else-if="isRejected">
      <div class="is-size-5 has-text-weight-semibold">
        {{ visitorGroupName }} hät äs Fotti vom Jokär
        {{ visitedJokerName }} igschickt, aber d Zentralä hät das abglehnt 😭
      </div>
    </template>
    <template v-else>
      <div class="is-size-5 has-text-weight-semibold">
        {{ visitorGroupName }} isch bim Jokär {{ visitedJokerName }} gsi. D
        Zentralä überprüäft das grad no 🔎
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
    <div v-if="jokerVisit.joker?.challenge" class="is-size-6 is-multiline-text">
      Challenge: {{ jokerVisit.joker?.challenge }}
    </div>
    <div v-if="jokerVisit.proofPhotoUrl">
      <a :href="jokerVisit.proofPhotoUrl" target="_blank">
        <span
          class="joker-visit-image"
          :style="{
            backgroundImage: `url('${jokerVisit.proofPhotoPreviewUrl}')`,
          }"
        ></span
      ></a>
    </div>
    <div class="is-size-6 is-multiline-text">
      {{ jokerVisit.operatorComment }}
    </div>
    <div v-if="canCallOperatorForBonus" class="mb-2">
      <p class="has-text-weight-bold">
        Zum {{ jokerVisit.joker.bonusCallValue }}.- Bonus übärzcho, chöndär no
        dä Zentralä aalütä.
      </p>
      <call-operator-button
        v-if="user && !isOperator"
        :user="user"
      ></call-operator-button>
    </div>
    <div v-if="isOperator">
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
          table="joker_visits"
          :id="jokerVisit.id"
          :value="jokerVisit.operatorComment"
        >
          Kommentiärä
        </comment-edit-modal>
        <bonus-points-modal
          v-if="jokerVisit.joker?.bonusCallValue"
          :max="jokerVisit.joker.bonusCallValue"
          :id="jokerVisit.id"
          :value="jokerVisit.earnedBonusValue"
        >
          Bonus vergä
        </bonus-points-modal>
      </o-field>
    </div>
    <div class="vac-text-timestamp">
      <span>{{ jokerVisit.createdAt?.toLocaleString() }}</span>
    </div>
  </message-box>
</template>

<script>
import MessageBox from '@/components/MessageBox'
import { useUserSession } from '@/stores/userSession'
import CallOperatorButton from '@/components/CallOperatorButton'
import { supabase } from '@/client'
import CommentEditModal from '@/components/CommentEditModal'
import BonusPointsModal from '@/components/BonusPointsModal'

export default {
  name: 'JokerVisitMessage',
  components: {
    BonusPointsModal,
    CommentEditModal,
    CallOperatorButton,
    MessageBox,
  },
  props: {
    jokerVisit: { type: Object, required: true },
    groupId: { type: Number, required: true },
    isOperator: { type: Boolean, default: false },
  },
  data: () => ({
    alwaysSpinning: true,
  }),
  computed: {
    user() {
      return useUserSession().user
    },
    isAccepted() {
      return !!this.jokerVisit.acceptedAt
    },
    isRejected() {
      return !!this.jokerVisit.rejectedAt
    },
    canCallOperatorForBonus() {
      return (
        !this.isRejected &&
        !!this.jokerVisit.joker?.bonusCallValue &&
        this.jokerVisit.earnedBonusValue === null
      )
    },
    visitorGroupName() {
      return this.jokerVisit.group?.name || 'Ä unbekannti Gruppä'
    },
    visitedJokerName() {
      return this.jokerVisit.joker?.name || 'ämä unbekanntä Jokär'
    },
    messageType() {
      return this.isAccepted
        ? 'success'
        : this.isRejected
        ? 'danger'
        : 'primary'
    },
  },
  methods: {
    async rate(rating) {
      await supabase.rpc('rate_joker_visit', {
        joker_visit_id: this.jokerVisit.id,
        rating,
      })
    },
  },
}
</script>

<style scoped></style>
