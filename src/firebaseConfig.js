import firebase from 'firebase/app'
import 'firebase/auth'
import 'firebase/database'

const year = '2019'

let config = {
  apiKey: 'AIzaSyAZwEsQJIMdrF5IlNn4R6qK0Rwekzf6Gs8',
  authDomain: 'gloggi-tramopoly.firebaseapp.com',
  databaseURL: 'https://gloggi-tramopoly.firebaseio.com',
  projectId: 'gloggi-tramopoly',
  storageBucket: 'gloggi-tramopoly.appspot.com',
  messagingSenderId: '874624059610'
}

let app = firebase.initializeApp(config)
let db = app.database()

let auth = firebase.auth()
let RecaptchaVerifier = firebase.auth.RecaptchaVerifier

export const groupsDB = db.ref(`${year}/groups`)
export const abteilungenDB = db.ref(`${year}/abteilungen`)
export { auth, RecaptchaVerifier }

export function bindUserByPhone (vm, member, phone) {
  vm.$watch(phone, (changedPhone) => {
    if (changedPhone) {
      vm.$bindAsObject(member, db.ref(`${year}/users/${changedPhone}`))
    }
  }, { immediate: true })
}

export function bindLoggedInUser (vm, member) {
  auth.onAuthStateChanged(loggedInUser => {
    if (loggedInUser) {
      vm.$bindAsObject(member, db.ref(`${year}/users/${loggedInUser.phoneNumber}`))
    } else if (vm._firebaseSources[member]) {
      vm.$unbind(member)
    }
  })
}
