<template>
  <div class="columns is-multiline">
    <tram-header>Tramopoly</tram-header>
    <div class="column is-full is-one-third-desktop is-offset-one-third-desktop has-text-centered">
      <slot v-if="operator" name="message"></slot>
      <div v-if="operator" class="card">
        <div class="card-content">
          <button v-if="!operatorBusy" class="button is-link is-outlined" @click="callOperator">📞 Zentralä ({{ operatorName }})</button>
          <button v-else-if="loggedInUserIsActiveCaller" class="button is-link is-outlined is-danger" @click="finishCall">🚫 Färtig telefoniärt</button>
          <button v-else class="button is-link is-outlined" @click="callOperator">🚫 Zentralä ({{ operatorName }} bsetzt)</button>
          <div class="is-size-7" style="margin-top: 10px;">{{ operatorPhoneInWords }}</div>
        </div>
      </div>
      <slot name="message2"></slot>
      <group-detail v-if="groupId" :group-id="groupId" :all-groups="allGroups" :update-interval="5"/>
      <div v-if="!groupIsCurrentlyMrT">
        <slot name="message3"></slot>
        <div class="card">
          <header class="card-header has-background-light"><h4 class="card-header-title title is-4">Wo isch dä Mr. T? 🕵️</h4></header>
          <div class="card-content"><p>{{ mrTLocation }}</p></div>
        </div>
      </div>
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
    operatorPhoneInWords () {
      if (!this.operatorPhone) return null
      let phoneFormat = this.operatorPhone.replace(/^\+41/g, '0').split('')
      if (phoneFormat.length === 10) {
        phoneFormat.splice(3, 0, ',')
        phoneFormat.splice(7, 0, ',')
        phoneFormat.splice(10, 0, ',')
      }
      return phoneFormat
        .join('')
        .replace(/0/g, ' Null')
        .replace(/1/g, ' Äis')
        .replace(/2/g, ' Zwäi')
        .replace(/3/g, ' Drüü')
        .replace(/4/g, ' Viär')
        .replace(/5/g, ' Foif')
        .replace(/6/g, ' Sächs')
        .replace(/7/g, ' Sibä')
        .replace(/8/g, ' Acht')
        .replace(/9/g, ' Nüün')
        .trim()
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
