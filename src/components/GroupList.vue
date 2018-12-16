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
      <b-table-column v-if="callingColumn" field="calling" label="Aktion">
        <transition name="fade" mode="out-in">
          <span v-if="loaded">
            <router-link class="button btn-primary is-outlined" :to="{ name: 'action', params: { caller: caller(props.row._key) } }">📞</router-link>
          </span>
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
    loaded: Boolean,
    callingColumn: { type: Boolean, default: false }
  },
  computed: {
    groupsOrDummy () {
      return this.loaded ? this.groups : [{}, {}, {}, {}, {}]
    }
  },
  methods: {
    caller (groupKey) {
      return 'test phone number'
    }
  }
}
</script>

<style scoped>

</style>
