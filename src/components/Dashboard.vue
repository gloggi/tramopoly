<template>
  <div class="box">
    <header class="title">Dashboard</header>
    <b-table :data="groups" :columns="groupTableColumns" striped hoverable></b-table>
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
