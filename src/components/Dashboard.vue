<template>
  <div class="columns is-multiline">
    <header class="title has-text-centered column is-full">Dashboard</header>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
         <b-table :data="groups" striped hoverable>
           <template slot-scope="props">
             <b-table-column field="name" label="Gruppä">{{ props.row.name }}</b-table-column>
             <b-table-column field="abteilung" label="Abteilig">{{ props.row.abteilung }}</b-table-column>
             <b-table-column field="delete" label="" numeric>
               <button class="button is-small is-danger" @click="deleteGroup(props.row)">
                 <b-icon icon="delete"></b-icon>
               </button>
             </b-table-column>
           </template>
         </b-table>
    </div>
  </div>
</template>

<script>
import { groupsDB } from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import BIcon from 'buefy/src/components/icon/Icon'

export default {
  name: 'Dashboard',
  components: { BIcon, BTable, BTableColumn },
  firebase: {
    groups: groupsDB
  },
  data () {
    return {}
  },
  methods: {
    deleteGroup (group) {
      groupsDB.child(group['.key']).remove()
    }
  }
}
</script>
