<template>
  <div
    class="card column is-full is-one-third-widescreen is-offset-one-third-widescreen"
  >
    <form @submit.prevent="register">
      <o-field label="Händynummärä"
        ><o-input
          type="tel"
          pattern="((\+41\s?)?|(0041\s?)?|0)7[6-9]\s?\d{3}\s?\d{2}\s?\d{2}"
          placeholder="079 het sie gseit"
          v-model="phone"
          autofocus
          required
      /></o-field>
      <o-field label="Pfadinamä">
        <o-input v-model="scoutName" required />
      </o-field>
      <o-field label="Gruppänamä">
        <o-autocomplete
          v-model="groupName"
          open-on-focus
          :data="groups"
          field="name"
          @select="(group) => (selectedGroup = group)"
          required
        />
      </o-field>
      <o-field v-if="selectedOrNamedGroup" label="Abteilig">
        <o-input v-model="selectedOrNamedGroup.abteilung.name" disabled />
      </o-field>
      <o-field v-else label="Abteilig">
        <o-select v-model="abteilung" expanded required>
          <option
            v-for="abteilung in abteilungen"
            :value="abteilung.id"
            :key="abteilung.id"
          >
            {{ abteilung.name }}
          </option>
        </o-select>
      </o-field>
      <o-field label="Ich telefoniär liäbär mit...">
        <o-select v-model="preferredCallMethod" expanded required>
          <option value="phone">Telefon</option>
          <option value="whatsapp">WhatsÄpp Aarüäf</option>
        </o-select>
      </o-field>
      <button class="button is-link" type="submit">Abschickä</button>
    </form>
  </div>
  <div
    v-if="shouldVerifyOtp"
    class="card column is-full is-one-third-widescreen is-offset-one-third-widescreen"
  >
    <form v-on:submit.prevent="verifyOtp">
      <o-field label="SMS-Code"
        ><o-input
          type="number"
          ref="otp"
          placeholder="000000"
          pattern="\d*"
          inputmode="numeric"
          v-model="otp"
          required
      /></o-field>
      <button class="button is-link" type="submit">SMS-Code beschtätigä</button>
    </form>
  </div>
</template>

<script setup>
import { storeToRefs } from 'pinia'
import { useAbteilungen } from '@/stores/abteilungen'
import { useGroups } from '@/stores/groups'

const abteilungenStore = useAbteilungen({
  filter: { active: true },
})
abteilungenStore.fetch()
const { all: abteilungen } = storeToRefs(abteilungenStore)

const groupsStore = useGroups({
  select: '*,abteilung:abteilungen(*,operator:operator_id(*))',
  filter: { active: true },
})
groupsStore.subscribe()
const { all: groups } = storeToRefs(groupsStore)
</script>

<script>
import { useUserSession } from '@/stores/userSession'
import { supabase } from '@/client'
import { showAlert } from '@/utils'
import { useGroups } from '@/stores/groups'

export default {
  name: 'RegisterView',
  data() {
    return {
      phone: '',
      scoutName: '',
      groupName: '',
      abteilung: '',
      preferredCallMethod: '',
      verifyPhoneNumber: import.meta.env.VITE_USE_TWILIO_PHONE_VERIFICATION,
      otp: '',
      confirmation: null,
      selectedGroup: null,
      savedUserData: null,
      savedPhone: null,
      savedGroupData: null,
    }
  },
  computed: {
    selectedOrNamedGroup() {
      if (this.selectedGroup) return this.selectedGroup
      return useGroups({
        select: '*,abteilung:abteilungen(*,operator:operator_id(*))',
        filter: { active: true },
      }).all.find(group => group.name === this.groupName)
    },
    normalizedPhone() {
      const cleaned = this.phone.trim().replace(/[^0-9+]/gi, '')
      // handle most swiss mobile phone numbers
      if (cleaned.startsWith('07')) {
        return '+41' + cleaned.substring(1)
      } else if (cleaned.startsWith('0041')) {
        return '+41' + cleaned.substring(4)
      }
      return cleaned
    },
    shouldVerifyOtp() {
      return this.verifyPhoneNumber && this.savedUserData
    },
  },
  methods: {
    async register() {
      this.savedGroupData = {
        name: this.groupName,
        abteilung_id: this.abteilung,
      }
      this.savedUserData = {
        group_id: this.selectedOrNamedGroup?.id,
        scout_name: this.scoutName,
        preferred_call_method: this.preferredCallMethod,
      }
      this.savedPhone = this.normalizedPhone
      const { error, data } = await supabase.auth.updateUser({
        phone: this.normalizedPhone,
      })
      if (error) {
        console.log(error)
        showAlert(
          'Öppis isch schiäf gangä. Probiär mal d Siitä neu z ladä oder s Tramopoly imnä anonymä Browsertab ufzmachä.'
        )
        return
      }

      if (this.verifyPhoneNumber) {
        // Direct the user to the OTP field
        this.$refs.otp.focus()
      } else {
        // If we don't have to verify the phone number, we can skip right ahead to saving the group
        await this.assignGroup()
      }
    },
    async verifyOtp() {
      if (!this.shouldVerifyOtp || !this.otp) return
      await this.withoutLosingSession(async () => {
        const { error } = await supabase.auth.verifyOtp({
          phone: this.savedPhone,
          token: this.otp,
          type: 'phone_change',
        })
        if (error) {
          console.log(error)
          showAlert(
            'Öppis isch schiäf gangä. Probiär mal d Siitä neu z ladä oder s Tramopoly imnä anonymä Browsertab ufzmachä.'
          )
        }
      })
      await this.assignGroup()
    },
    async withoutLosingSession(callback) {
      /**
       * Supabase throws away the active session while verifying the SMS OTP code. This is needed for
       * phone authentication, but not for phone number changes which we are doing. This function temporarily
       * patches supabase so this does not happen. Might well break (or be fixed for real) in the future.
       */
      const original = supabase.auth._removeSession
      supabase.auth._removeSession = () => {}
      try {
        await callback()
      } catch (e) {
        console.error(e)
      }
      supabase.auth._removeSession = original
    },
    async assignGroup() {
      if (!this.savedUserData.group_id) {
        const { data, error } = await supabase
          .from('groups')
          .insert([this.savedGroupData])
          .select()
          .single()
        if (error) {
          console.log(error)
          showAlert(
            'Bim Gruppä erstellä isch öppis schiäf gangä. Mäld dich bitte bim Cosinus (klick uf "Hilfe").'
          )
          return
        }
        this.savedUserData.group_id = data.id
      }
      const userSession = useUserSession()
      const { error } = await supabase
        .from('registerable_profiles')
        .update(this.savedUserData)
        .eq('row_num', 1) // filtering is required for UPDATE calls, so we add a filter on a dummy column
      if (error) {
        console.log(error)
        showAlert(
          'Bim Fertigstellä vo dim Account isch öppis schiäf gangä. Mäld dich bitte bim Cosinus (klick uf "Hilfe").'
        )
        return
      }
      await userSession.fetchAuth()
    },
  },
}
</script>

<style lang="scss">
input[type='number']::-webkit-outer-spin-button,
input[type='number']::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}
input[type='number'] {
  -moz-appearance: textfield;
}
</style>
