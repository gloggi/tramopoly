<template>
  <div class="columns is-multiline">
    <header class="title has-text-centered column is-full is-one-third-desktop is-offset-one-third-desktop">Login</header>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      <form v-on:submit.prevent="login">
        <b-field label="Händynummärä"><b-input type="tel" pattern="((\+41\s?)?|(0041\s?)?|0)7[6-9]\s?\d{3}\s?\d{2}\s?\d{2}" placeholder="079 het sie gseit" v-model="phone" autofocus/></b-field>
        <b-field label="Gruppänamä">
          <b-autocomplete v-if="!userIsAlreadyRegistered" v-model="groupName" open-on-focus :data="groups" field="name"/>
          <b-input v-else v-model="specifiedUser.groupName" disabled />
        </b-field>
        <b-field label="Abteilig">
          <b-select v-if="!groupIsAlreadyRegistered" v-model="abteilung" expanded>
            <option v-for="abteilung in abteilungen" :value="abteilung['.value']" :key="abteilung['.value']">{{ abteilung['.value'] }}</option>
          </b-select>
          <b-input v-else v-model="specifiedGroup.abteilung" disabled />
        </b-field>
        <button class="button is-link" type="submit">Iiloggä</button>
      </form>
    </div>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      <form v-on:submit.prevent="verifyOtp">
        <b-field label="SMS-Code"><b-input type="number" ref="otp" placeholder="000000" pattern="\d*" inputmode="numeric" v-model="otp"/></b-field>
        <button class="button is-link" type="submit">SMS-Code beschtätigä</button>
      </form>
    </div>
    <div id="recaptcha-container"></div>
  </div>
</template>

<script>
import { auth, RecaptchaVerifier, groupsDB, abteilungenDB, bindUserByPhone } from '@/firebaseConfig'
import BField from 'buefy/src/components/field/Field'
import BInput from 'buefy/src/components/input/Input'
import BAutocomplete from 'buefy/src/components/autocomplete/Autocomplete'
import BSelect from 'buefy/src/components/select/Select'

export default {
  components: { BSelect, BAutocomplete, BInput, BField },
  firebase: {
    groups: groupsDB.orderByChild('name'),
    abteilungen: abteilungenDB.orderByValue()
  },
  data () {
    return {
      phone: '',
      groupName: '',
      abteilung: '',
      otp: '',
      appVerifier: null,
      confirmation: null,
      specifiedUser: {}
    }
  },
  computed: {
    normalizedPhone () {
      let cleaned = this.phone.trim().replace(/[^0-9+]/gi, '')
      // handle most swiss mobile phone numbers
      if (cleaned.startsWith('07')) {
        return '+41' + cleaned.substr(1)
      } else if (cleaned.startsWith('0041')) {
        return '+41' + cleaned.substr(4)
      }
      return cleaned
    },
    userIsAlreadyRegistered () {
      return this.specifiedUser.hasOwnProperty('groupName')
    },
    specifiedGroup () {
      return this.groups.find(group => group.name === (this.userIsAlreadyRegistered ? this.specifiedUser.groupName : this.groupName))
    },
    groupIsAlreadyRegistered () {
      return this.specifiedGroup !== undefined
    }
  },
  methods: {
    login () {
      auth.signInWithPhoneNumber(this.normalizedPhone, this.appVerifier)
        .then(result => {
          this.confirmation = result
          console.log('SMS sent')
          this.$refs.otp.focus()
        }).catch(error => {
          console.error('SMS not sent, error code ', error.code, ': ', error.message)
        })
    },
    verifyOtp () {
      if (this.confirmation === null) return
      this.confirmation.confirm(this.otp).then(result => {
        console.log('login success ', result)
        this.$router.push('/')
      })
    },
    initRecaptcha () {
      this.appVerifier = new RecaptchaVerifier('recaptcha-container', {
        'size': 'invisible',
        'callback': function () {
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
  created () {
    this.$watch('normalizedPhone', (phone) => {
      bindUserByPhone(this, 'specifiedUser', phone)
    }, { immediate: true })
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
