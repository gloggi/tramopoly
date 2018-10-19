<template>
  <div>
    <h1>Dashboard</h1>
    <table>
      <thead>
        <tr>
          <td>Gruppe</td>
          <td>Abteilung</td>
        </tr>
      </thead>
      <tbody>
        <tr v-for="group in groups" v-bind:key="group.name">
          <td>{{group.name}}</td>
          <td>{{group.abteilung}}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { groupsRef } from '@/firebaseConfig'

export default {
  name: 'Dashboard',
  firebase: {
    groups: groupsRef
  }
}
</script>
