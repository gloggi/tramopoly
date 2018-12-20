import firebase from 'firebase/app'
import 'firebase/firestore'
import 'firebase/auth'
import 'firebase/database'

let config = {
  apiKey: 'AIzaSyAayb2jkXiBRdyqVlaAWuOTTQNA9waqtmA',
  authDomain: 'tramopoly-92c49.firebaseapp.com',
  databaseURL: 'https://tramopoly-92c49.firebaseio.com',
  projectId: 'tramopoly-92c49',
  storageBucket: '',
  messagingSenderId: '414240119625'
}

firebase.initializeApp(config)
const db = firebase.firestore()
db.settings({ timestampsInSnapshots: true })

let auth = firebase.auth()
let RecaptchaVerifier = firebase.auth.RecaptchaVerifier

export const groupsDB = db.collection('groups')
export const abteilungenDB = db.collection('abteilungen')
export { auth, RecaptchaVerifier }

export function bindUserByPhone (vm, member, phone) {
  vm.$watch(phone, (changedPhone) => {
    if (changedPhone) {
      vm.$bind(member, db.collection('users').doc(changedPhone))
    }
  }, { immediate: true })
}

export function bindLoggedInUser (vm, member, cancelCallback, readyCallback) {
  auth.onAuthStateChanged(loggedInUser => {
    if (loggedInUser) {
      vm.$bind(member, db.collection('users').doc(loggedInUser.phoneNumber)).then(readyCallback).catch(cancelCallback)
    } else if (vm.$firestoreRefs && vm.$firestoreRefs[member]) {
      vm.$unbind(member)
    }
  })
}

export function requireAuth (to, from, next) {
  auth.onAuthStateChanged(user => {
    if (!user) {
      return next('/login')
    }
    next(vm => {
      bindLoggedInUser(vm, 'loggedInUser')
    })
  })
}

export function requireOperator (to, from, next) {
  next(vm => {
    bindLoggedInUser(vm, 'loggedInOperator', null, () => {
      if (!vm.loggedInOperator || !vm.loggedInOperator['isOperator']) {
        vm.$router.replace({ name: 'index' })
      }
    })
  })
}
