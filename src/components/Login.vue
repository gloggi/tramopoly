<template>
  <div>
    <h2>Login</h2>
    <input type="tel" placeholder="Handynummärä" v-model="phone"/><br>
    <input type="text" placeholder="Gruppänamä" v-model="groupName"/><br/>
    <button @click="login">Iiloggä</button>
    <div id="recaptcha-container"></div>
    <input type="text" placeholder="SMS-Code" v-model="otp"/><br/>
    <button @click="verifyOtp">SMS-Code beschtätigä</button>
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
          console.error('SMS not sent, error: ', error)
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
