<template>
  <div class="columns is-multiline">
    <header class="title has-text-centered column is-full">Dashboard</header>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
         <b-table :data="groups" :columns="groupTableColumns" striped hoverable></b-table>
    </div>
  </div>
</template>

<script>
import { groupsDB } from '@/firebaseConfig'
import BTable from 'buefy/src/components/table/Table'

export default {
  name: 'Dashboard',
  components: { BTable },
  firebase: {
    groups: groupsDB
  },
  data () {
    return {
      groupTableColumns: [
        { field: 'name', label: 'Gruppä' },
        { field: 'abteilung', label: 'Abteilig' }
      ]
    }
  }
}
</script>
