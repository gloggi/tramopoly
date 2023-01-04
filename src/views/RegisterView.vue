<template>
  <div
    class="card column is-full is-one-third-desktop is-offset-one-third-desktop"
  >
    <form v-on:submit.prevent="register">
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
      <o-field v-if="existingGroup" label="Abteilig">
        <o-input v-model="existingGroup.abteilung.name" disabled />
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
    class="card column is-full is-one-third-desktop is-offset-one-third-desktop"
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

<script>
import { useUserSessionStore } from '@/stores/userSession'
import { supabase } from '@/client'
import { showAlert } from '@/utils'

export default {
  name: 'RegisterView',
  data() {
    const userSession = useUserSessionStore()
    return {
      userSession,
      phone: '',
      scoutName: '',
      groupName: '',
      abteilung: '',
      preferredCallMethod: '',
      groups: [],
      verifyPhoneNumber: import.meta.env.VITE_USE_TWILIO_PHONE_VERIFICATION,
      otp: '',
      confirmation: null,
      selectedGroup: null,
      abteilungen: [],
      savedUserData: null,
      savedGroupData: null,
    }
  },
  computed: {
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
    existingGroup() {
      return (
        this.selectedGroup ||
        this.groups.find((group) => group.name === this.groupName)
      )
    },
    shouldVerifyOtp() {
      return this.verifyPhoneNumber && this.savedUserData
    },
  },
  mounted() {
    this.fetchAbteilungen()
    this.fetchGroups()
  },
  methods: {
    async fetchAbteilungen() {
      const { data } = await supabase
        .from('abteilungen')
        .select()
        .eq('active', true)
      this.abteilungen = data
    },
    async fetchGroups() {
      const { data } = await supabase
        .from('groups')
        .select('id,name,abteilung:abteilungen(id,name)')
        .eq('active', true)
      this.groups = data
    },
    async register() {
      this.savedGroupData = {
        name: this.groupName,
        abteilung_id: this.abteilung,
      }
      this.savedUserData = {
        phone: this.normalizedPhone,
        group_id: this.existingGroup?.id,
      }
      const { error } = await supabase.auth.updateUser({
        ...(this.verifyPhoneNumber ? { phone: this.normalizedPhone } : {}),
        data: {
          phone: this.normalizedPhone,
          scout_name: this.scoutName,
          preferred_call_method: this.preferredCallMethod,
        },
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
        const { data, error } = await supabase.auth.verifyOtp({
          phone: this.savedUserData.phone,
          token: this.otp,
          type: 'phone_change',
        })
        if (error) {
          console.log(error)
          showAlert(
            'Öppis isch schiäf gangä. Probiär mal d Siitä neu z ladä oder s Tramopoly imnä anonymä Browsertab ufzmachä.'
          )
          return
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
      const { error } = await supabase.auth.updateUser({
        data: {
          group_id: this.savedUserData.group_id,
        },
      })
      if (error) {
        console.log(error)
        showAlert(
          'Bim Zuewiisä vo dim Account zu de Gruppä isch öppis schiäf gangä. Mäld dich bitte bim Cosinus (klick uf "Hilfe").'
        )
        return
      }
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
