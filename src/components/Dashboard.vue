<template>
  <div class="tile is-parent is-vertical">
    <div class="box tile is-child">
      <header class="title">Dashboard</header>
      <b-table :data="groups" :columns="groupTableColumns" striped hoverable></b-table>
    </div>
  </div>
</template>

<script>
import { groupsRef } from '@/firebaseConfig'

export default {
  name: 'Dashboard',
  firebase: {
    groups: groupsRef
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
