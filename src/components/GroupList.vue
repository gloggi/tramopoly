<template>
  <b-table :data="groupsOrDummy" striped hoverable>
    <template slot-scope="props">
      <b-table-column field="name" label="Gruppä">
        <transition name="fade" mode="out-in">
          <span v-if="loaded">{{ props.row.name }}</span>
          <placeholder v-else></placeholder>
        </transition>
      </b-table-column>
      <b-table-column field="abteilung" label="Abteilig">
        <transition name="fade" mode="out-in">
          <span v-if="loaded">{{ props.row.abteilung }}</span>
          <placeholder v-else></placeholder>
        </transition>
      </b-table-column>
    </template>
  </b-table>
</template>

<script>
import BTable from 'buefy/src/components/table/Table'
import BTableColumn from 'buefy/src/components/table/TableColumn'
import Placeholder from '@/components/Placeholder'
export default {
  name: 'GroupList',
  components: { Placeholder, BTableColumn, BTable },
  props: {
    groups: Array,
    loaded: Boolean
  },
  computed: {
    groupsOrDummy () {
      return this.loaded ? this.groups : [{}, {}, {}, {}, {}]
    }
  }
}
</script>

<style scoped>

</style>
