<template>
  <div class="columns is-multiline">
    <tram-header>Zentralä</tram-header>
    <div class="column is-full is-one-third-desktop is-offset-one-third-desktop has-text-centered">
      <div v-if="loggedInOperatorBusy" class="card">
        <div class="card-content">
          <header class="card-header-title is-centered">Aktivä Aruäf: {{ loggedInOperator.activeCall.scoutName }}</header>
          <button @click="clearActiveCall" class="button is-danger">Aktivä Aruäf beändä</button>
        </div>
      </div>
      <div class="card">
        <b-table class="has-content-vcentered" :data="allGroups" striped hoverable selectable @select="selectGroup" :row-class="markIfCallingGroup">
          <template slot-scope="props">
            <b-table-column field="abteilung.name" width="32">
              <span class="icon is-medium"><img :title="props.row.abteilung.name" style="opacity: 0.7" :src="require('../../static/' + props.row.abteilung.id + '.svg')"/></span>
            </b-table-column>
            <b-table-column field="name" label="Gruppä"><span>{{ props.row.name }}</span><b-tag v-if="props.row.isCurrentlyMrT" type="is-info" class="is-small is-pulled-right" title="🕵️">Mr. T</b-tag></b-table-column>
            <b-table-column field="saldo" label="Saldo" numeric>{{ props.row.saldo }}.-</b-table-column>
            <b-table-column field="realEstatePoints" label="Immobiliä" numeric>{{ props.row.realEstatePoints }}</b-table-column>
            <b-table-column field="mrTPoints" label="Mr T." numeric>{{ props.row.mrTPoints }}</b-table-column>
            <b-table-column field="totalPoints" label="Total" numeric>{{ props.row.totalPoints }}</b-table-column>
          </template>
        </b-table>
      </div>
      <slot name="message"></slot>
    </div>
  </div>
</template>

<script>
import { requireOperator, setActiveCall } from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import TramHeader from '@/components/TramHeader'
import Placeholder from '@/components/Placeholder'

export default {
  name: 'Zentrale',
  components: { Placeholder, BTable, BTableColumn, TramHeader },
  props: {
    allGroups: { type: Array, required: true }
  },
  data () {
    return {
      loggedInOperator: null
    }
  },
  beforeRouteEnter (to, from, next) {
    requireOperator(to, from, next)
  },
  computed: {
    loggedInOperatorBusy () {
      return !!(this.loggedInOperator && this.loggedInOperator.activeCall)
    }
  },
  methods: {
    clearActiveCall () {
      setActiveCall(this.loggedInOperator.id, null)
    },
    selectGroup (group) {
      this.$router.push({ name: 'action', params: { group: group.id } })
    },
    markIfCallingGroup (group) {
      return (this.loggedInOperator &&
        this.loggedInOperator.activeCall &&
        this.loggedInOperator.activeCall.group &&
        this.loggedInOperator.activeCall.group.id === group.id) ? 'is-active-call is-clickable has-content-vcentered' : 'is-clickable has-content-vcentered'
    }
  }
}
</script>
