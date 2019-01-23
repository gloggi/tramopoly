<template>
  <div class="columns is-multiline">
    <tram-header>Tramopoly</tram-header>
    <div class="column is-full is-one-third-desktop is-offset-one-third-desktop has-text-centered">
      <div v-if="operator" class="card">
        <div class="card-content">
          <button v-if="!operatorBusy" class="button is-link is-outlined" @click="callOperator">📞 Zentralä ({{ operatorName }})</button>
          <button v-else-if="loggedInUserIsActiveCaller" class="button is-link is-outlined is-danger" @click="finishCall">🚫 Färtig telefoniärt</button>
          <button v-else class="button is-link is-outlined" @click="callOperator">🚫 Zentralä ({{ operatorName }} bsetzt)</button>
        </div>
      </div>
      <slot name="message"></slot>
      <group-detail v-if="groupId" :group-id="groupId" :all-groups="allGroups" :update-interval="5"/>
      <div v-if="!groupIsCurrentlyMrT">
        <slot name="message2"></slot>
        <div class="card">
          <header class="card-header has-background-light"><h4 class="card-header-title title is-4">Wo isch dä Mr. T? 🕵️</h4></header>
          <div class="card-content"><p>{{ mrTLocation }}</p></div>
        </div>
      </div>
      <slot name="message3"></slot>
    </div>
  </div>
</template>

<script>
import { bindUserById, requireAuth, setActiveCall } from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import Placeholder from '@/components/Placeholder'
import TramHeader from '@/components/TramHeader'
import GroupDetail from '@/components/GroupDetail'

export default {
  components: { GroupDetail, Placeholder, BTable, BTableColumn, TramHeader },
  props: {
    allGroups: { type: Array, required: true },
    mrTLocation: { type: String, required: true }
  },
  data () {
    return {
      loggedInUser: null,
      operator: null
    }
  },
  beforeRouteEnter (to, from, next) {
    requireAuth(to, from, next, vm => () => {
      if (vm.loggedInUser.role === 'operator') vm.$router.replace({ name: 'zentrale' })
    })
  },
  computed: {
    groupId () {
      return this.loggedInUser && this.loggedInUser.group && this.loggedInUser.group.id
    },
    operatorName () {
      return this.operator ? this.operator.scoutName : null
    },
    operatorPhone () {
      return this.operator ? this.operator.phone : null
    },
    operatorId () {
      return this.operator ? this.operator.id : null
    },
    operatorBusy () {
      return !!(this.operator && this.operator.activeCall)
    },
    loggedInUserIsActiveCaller () {
      return this.operatorBusy && this.operator.activeCall.id === this.loggedInUser.id
    },
    groupIsCurrentlyMrT () {
      return !!(this.currentMrT && this.currentMrT.id === this.groupId)
    },
    currentMrT () {
      return this.allGroups.find(group => group.isCurrentlyMrT)
    }
  },
  methods: {
    callOperator () {
      setActiveCall(this.operatorId, this.loggedInUser.id).then(() => {
        window.location = 'tel:' + this.operatorPhone
      })
    },
    finishCall () {
      if (this.loggedInUserIsActiveCaller) {
        setActiveCall(this.operatorId, null)
      }
    }
  },
  watch: {
    'loggedInUser.group.abteilung.operator': function (newOperator) {
      if (newOperator.id) {
        bindUserById(this, 'operator', newOperator.id)
      }
    }
  }
}
</script>
