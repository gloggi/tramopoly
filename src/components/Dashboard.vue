<template>
  <div class="columns is-multiline">
    <header class="title has-text-centered column is-full">Dashboard</header>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      <b-table :data="groupsOrDummy" striped hoverable>
        <template slot-scope="props">
            <b-table-column field="name" label="Gruppä">
              <transition name="fade" mode="out-in">
                <span v-if="groupsLoaded">{{ props.row.name }}</span>
                <placeholder v-else></placeholder>
              </transition>
            </b-table-column>
            <b-table-column field="abteilung" label="Abteilig">
              <transition name="fade" mode="out-in">
                <span v-if="groupsLoaded">{{ props.row.abteilung }}</span>
                <placeholder v-else></placeholder>
              </transition>
            </b-table-column>
            <b-table-column field="delete" label="" width="44">
              <transition name="fade" mode="out-in">
                <button v-if="groupsLoaded" class="button is-small is-danger" @click="deleteGroup(props.row)">
                  <b-icon icon="delete"></b-icon>
                </button>
                <button v-else class="button is-small is-danger" disabled>
                  <b-icon icon="delete"></b-icon>
                </button>
              </transition>
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
import Placeholder from '@/components/Placeholder'

export default {
  name: 'Dashboard',
  components: { Placeholder, BIcon, BTable, BTableColumn },
  firebase: {
    groups: groupsDB
  },
  data () {
    return {}
  },
  computed: {
    groupsLoaded () {
      return this.groups && this.groups.length
    },
    groupsOrDummy () {
      return this.groupsLoaded ? this.groups : [{}, {}, {}, {}, {}]
    }
  },
  methods: {
    deleteGroup (group) {
      groupsDB.child(group['.key']).remove()
    }
  }
}
</script>

<style scoped>
  .fade-enter-active, .fade-leave-active {
    transition: opacity .2s;
    position: absolute;
  }
  .fade-enter, .fade-leave-to {
    opacity: 0;
  }
</style>
