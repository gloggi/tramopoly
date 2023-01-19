<template>
  <div class="card" v-if="users.length">
    <header class="card-header has-background-light">
      <span class="card-header-title title is-4">🧒 Benutzär</span>
    </header>
    <o-table
      table-class="has-content-vcentered"
      :data="users"
      striped
      hoverable
      default-sort="scoutName"
      :row-class="() => 'has-content-vcentered'"
    >
      <o-table-column
        #default="{ row }"
        field="scoutName"
        label="Namä"
        sortable
      >
        <span>
          <span class="has-text-weight-bold">{{ row.scoutName }}</span>

          <span
            v-if="isCurrentlyMrT(row).value"
            class="tag is-info is-pulled-right is-small mb-2 is-valign-text-top"
            title="🕵️"
          >
            Mr. T
          </span>
        </span>
      </o-table-column>
      <o-table-column
        #default="{ row }"
        field="phone"
        label="Telefon"
        sortable
        numeric
        :td-attrs="() => ({ align: 'left' })"
        >{{ row.phone }}</o-table-column
      >
      <o-table-column
        #default="{ row }"
        field="group.abteilung.name"
        label="Abteilig"
        sortable
      >
        <span v-if="row.group && row.group.abteilung">
          <span v-if="row.group.abteilung.logoUrl" class="icon is-medium">
            <img
              :title="row.group.abteilung.name"
              :alt="row.group.abteilung.name"
              style="opacity: 0.7"
              :src="row.group.abteilung.logoUrl"
            />
          </span>
          <span>
            {{ row.group.abteilung.name }}
          </span>
        </span>
      </o-table-column>
      <o-table-column
        #default="{ row }"
        field="group.name"
        label="Gruppä"
        sortable
      >
        <span>
          <o-select
            @update:modelValue="(value) => changeGroup(row.id, value)"
            :model-value="row.groupId"
          >
            <option v-for="group in groups" :key="group.id" :value="group.id">
              {{ group.name }}
            </option>
          </o-select>
        </span>
      </o-table-column>
      <o-table-column #default="{ row }" field="role" label="Rollä" sortable>
        <span>
          <o-select
            @update:modelValue="(value) => changeRole(row.id, value)"
            :model-value="row.role"
          >
            <option value="player">Spielär</option>
            <option value="operator">Zentralä</option>
            <option value="admin">Admin</option>
          </o-select>
        </span>
      </o-table-column>
    </o-table>
  </div>
</template>

<script setup>
import { useProfiles } from '@/stores/profiles'
import { storeToRefs } from 'pinia'
import { supabase } from '@/client'
import { useGroups } from '@/stores/groups'
import { computed } from 'vue'

const profilesStore = useProfiles({
  select: '*,group:group_id(*,abteilung:abteilung_id(*))',
})
profilesStore.subscribe()
const { all: users } = storeToRefs(profilesStore)

const groupsStore = useGroups()
groupsStore.subscribe()
const { all: groups } = storeToRefs(groupsStore)

const changeRole = async (id, newRole) => {
  await supabase.from('profiles').update({ role: newRole }).eq('id', id)
}

const changeGroup = async (id, newGroupId) => {
  await supabase.from('profiles').update({ group_id: newGroupId }).eq('id', id)
}

// TODO
const currentMrT = null

const isCurrentlyMrT = (user) => {
  return computed(() => user.groupId === currentMrT?.id)
}
</script>

<script>
export default {
  name: 'UserManagement',
}
</script>
