<template>
  <div class="columns is-multiline">
    <header class="title column is-full is-one-third-desktop is-offset-one-third-desktop">Login</header>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      <form v-on:submit.prevent="login">
        <b-field label="Händynummärä"><b-input type="tel" pattern="((\+41\s?)?|(0041\s?)?|0)7[6-9]\s?\d{3}\s?\d{2}\s?\d{2}" placeholder="079 het sie gseit" v-model="phone"/></b-field>
        <b-field label="Gruppänamä"><b-input type="text" v-model="groupName"/></b-field>
        <button class="button is-link" type="submit">Iiloggä</button>
      </form>
    </div>
    <div class="box column is-full is-one-third-desktop is-offset-one-third-desktop">
      <form v-on:submit.prevent="verifyOtp">
        <b-field label="SMS-Code"><b-input type="text" ref="otp" placeholder="000000" pattern="[0-9]{6}" v-model="otp"/></b-field>
        <button class="button is-link" type="submit">SMS-Code beschtätigä</button>
      </form>
    </div>
    <div id="recaptcha-container"></div>
  </div>
</template>

<script>
import { auth, RecaptchaVerifier } from '@/firebaseConfig'
import BField from 'buefy/src/components/field/Field'
import BInput from 'buefy/src/components/input/Input'

export default {
  components: { BInput, BField },
  data () {
    return {
      phone: '',
      groupName: '',
      otp: '',
      appVerifier: null,
      confirmation: null
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
  }
}
</script>
