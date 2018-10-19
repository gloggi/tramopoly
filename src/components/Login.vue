<template>
  <div>
    <h2>Login</h2>
    <form v-on:submit.prevent="login">
      <input type="tel" placeholder="Handynummärä" v-model="phone"/><br>
      <input type="text" placeholder="Gruppänamä" v-model="groupName"/><br/>
      <button type="submit">Iiloggä</button>
    </form>
    <div id="recaptcha-container"></div>
    <form v-on:submit.prevent="verifyOtp">
      <input type="text" placeholder="SMS-Code" v-model="otp"/><br/>
      <button type="submit">SMS-Code beschtätigä</button>
    </form>
  </div>
</template>

<script>
import { auth } from '@/firebaseConfig'

export default {
  data () {
    return {
      phone: '',
      groupName: '',
      otp: '',
      appVerifier: null,
      confirmation: null
    }
  },
  methods: {
    login () {
      auth().signInWithPhoneNumber(this.phone, this.appVerifier)
        .then(result => {
          this.confirmation = result
          console.log('SMS sent')
        }).catch(error => {
          console.error('SMS not sent, error code ', error.code, ': ', error.message)
        })
    },
    verifyOtp () {
      if (this.confirmation === null) return
      this.confirmation.confirm(this.otp).then(result => {
        console.log('login success ', result)
        this.$router.push('dashboard')
      })
    },
    initRecaptcha () {
      this.appVerifier = new auth.RecaptchaVerifier('recaptcha-container', {
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
