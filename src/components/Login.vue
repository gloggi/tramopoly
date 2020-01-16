<template>
  <div class="columns is-multiline">
    <tram-header>Login</tram-header>
    <div class="card column is-full is-one-third-desktop is-offset-one-third-desktop">
      <form v-on:submit.prevent="login">
        <b-field label="Händynummärä"><b-input type="tel" pattern="((\+41\s?)?|(0041\s?)?|0)7[6-9]\s?\d{3}\s?\d{2}\s?\d{2}" placeholder="079 het sie gseit" v-model="phone" autofocus required/></b-field>
        <b-field label="Pfadinamä">
          <b-input v-if="!userIsAlreadyRegistered" v-model="scoutName" required />
          <b-input v-else v-model="specifiedUser.scoutName" disabled />
        </b-field>
        <b-field label="Gruppänamä">
          <b-autocomplete v-if="!userIsAlreadyRegistered" v-model="groupName" open-on-focus :data="groups" field="name" @select="group => selectedGroup = group" required/>
          <b-input v-else v-model="specifiedUser.group.name" disabled />
        </b-field>
        <b-field label="Abteilig">
          <b-select v-if="!groupIsAlreadyRegistered" v-model="abteilung" expanded required>
            <option v-for="abteilung in abteilungen" :value="abteilung" :key="abteilung.name">{{ abteilung.name }}</option>
          </b-select>
          <b-input v-else-if="specifiedGroup.abteilung" v-model="specifiedGroup.abteilung.name" disabled />
          <b-input v-else disabled />
        </b-field>
        <b-field label="Ich telefoniär liäbär mit...">
          <b-select v-model="preferWhatsApp" expanded required>
            <option :value="false">Telefon</option>
            <option :value="true">WhatsApp Aarüäf</option>
          </b-select>
        </b-field>
        <button class="button is-link" type="submit">Iiloggä</button>
      </form>
    </div>
    <div class="card column is-full is-one-third-desktop is-offset-one-third-desktop">
      <form v-on:submit.prevent="verifyOtp">
        <b-field label="SMS-Code"><b-input type="number" ref="otp" placeholder="000000" pattern="\d*" inputmode="numeric" v-model="otp" required/></b-field>
        <button class="button is-link" type="submit">SMS-Code beschtätigä</button>
      </form>
    </div>
    <div id="recaptcha-container"></div>
  </div>
</template>

<script>
import {
  abteilungenDB,
  addGroup,
  addUser,
  auth,
  bindUserByPhone,
  groupsDB,
  RecaptchaVerifier,
  setWhatsAppPreference
} from '../firebaseConfig'
import TramHeader from '../components/TramHeader'

export default {
  name: 'Login',
  components: { TramHeader },
  firestore: {
    activeAndInactiveGroups: groupsDB.orderBy('name'),
    abteilungen: abteilungenDB.where('active', '==', true)
  },
  data () {
    return {
      phone: '',
      scoutName: '',
      groupName: '',
      abteilung: '',
      preferWhatsApp: false,
      otp: '',
      appVerifier: null,
      confirmation: null,
      specifiedUser: null,
      selectedGroup: null,
      activeAndInactiveGroups: [],
      abteilungen: [],
      specifiedUserData: {}
    }
  },
  computed: {
    normalizedPhone () {
      const cleaned = this.phone.trim().replace(/[^0-9+]/gi, '')
      // handle most swiss mobile phone numbers
      if (cleaned.startsWith('07')) {
        return '+41' + cleaned.substr(1)
      } else if (cleaned.startsWith('0041')) {
        return '+41' + cleaned.substr(4)
      }
      return cleaned
    },
    userIsAlreadyRegistered () {
      return this.specifiedUser && Object.prototype.hasOwnProperty.call(this.specifiedUser, 'group')
    },
    groups () {
      return this.activeAndInactiveGroups.filter(group => group.active)
    },
    specifiedGroup () {
      if (this.userIsAlreadyRegistered) return this.specifiedUser.group
      return this.selectedGroup || this.groups.find(group => group.name === this.groupName)
    },
    groupIsAlreadyRegistered () {
      return !!this.specifiedGroup
    }
  },
  methods: {
    login () {
      this.specifiedGroupData = { name: this.groupName, abteilung: this.abteilung, active: true }
      this.specifiedUserData = { phone: this.normalizedPhone, scoutName: this.scoutName, group: this.groupName, preferWhatsApp: this.preferWhatsApp, role: '' }
      auth.signInWithPhoneNumber(this.specifiedUserData.phone, this.appVerifier)
        .then(result => {
          this.confirmation = result
          console.log('SMS sent')
          this.$refs.otp.focus()
        }).catch(error => {
          console.error('SMS not sent, error code', error.code, error.message)
        })
    },
    async verifyOtp () {
      if (this.confirmation === null) return
      const result = await this.confirmation.confirm(this.otp)
      console.log('login success ', result)
      if (!this.groupIsAlreadyRegistered) {
        const groupRef = await addGroup(this.specifiedGroupData, this.groups)
        console.log('group created', groupRef)
        this.specifiedUserData.group = groupRef
      } else {
        this.specifiedUserData.group = groupsDB.doc(this.specifiedGroup.id)
      }
      if (!this.userIsAlreadyRegistered) {
        await addUser(result.user.uid, this.specifiedUserData)
        console.log('user created')
      } else {
        await setWhatsAppPreference(result.user.uid, this.specifiedUserData.preferWhatsApp)
      }
      this.$emit('login')
      this.$router.push({ name: 'index' })
    },
    initRecaptcha () {
      this.appVerifier = new RecaptchaVerifier('recaptcha-container', {
        size: 'invisible',
        callback: function () {
          console.log('ReCaptcha success')
        },
        'expired-callback': function () {
          console.log('ReCaptcha expired')
        }
      })
    }
  },
  mounted () {
    this.initRecaptcha()
  },
  watch: {
    normalizedPhone: function (changedPhone) {
      bindUserByPhone(this, 'specifiedUser', changedPhone)
    },
    specifiedUser: function (changedUser) {
      if (changedUser) {
        this.preferWhatsApp = changedUser.preferWhatsApp
      }
    }
  }
}
</script>

<style>
  input[type="number"]::-webkit-outer-spin-button,
  input[type="number"]::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
  }
  input[type="number"] {
    -moz-appearance: textfield;
  }
</style>
