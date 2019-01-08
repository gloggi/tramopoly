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
export const stationsDB = db.collection('stations')
export const jokersDB = db.collection('jokers')
export const settingsDB = db.collection('settings').doc('settings')
export const stationVisitsDB = db.collection('stationVisits').where('time', '>', new Date(0)).orderBy('time')
export const jokerVisitsDB = db.collection('jokerVisits').where('time', '>', new Date(0)).orderBy('time')
export { auth, RecaptchaVerifier }

export function bindUserByReactivePhone (vm, member, phone) {
  vm.$watch(phone, (changedPhone) => {
    if (changedPhone) {
      db.collection('users').where('phone', '==', changedPhone).onSnapshot(snapshot => {
        if (!snapshot.empty) {
          vm.$bind(member, db.collection('users').doc(snapshot.docs[0].id))
        }
      })
    }
  }, { immediate: true })
}

export function bindUserById (vm, member, uid) {
  if (uid !== null) {
    vm.$bind(member, db.collection('users').doc(uid))
  } else {
    vm.$unbind(member)
  }
}

export function updateUser (uid, changes) {
  return db.collection('users').doc(uid).update(changes)
}

export function addStationVisit (groupId, stationId) {
  let time = new Date()
  return db.collection('stationVisits').doc(time.toLocaleTimeString('de-CH') + ' ' + groupId + ' ' + stationId).set({
    group: db.collection('groups').doc(groupId),
    station: db.collection('stations').doc(stationId),
    time
  })
}

export function addJokerVisit (groupId, jokerId) {
  let time = new Date()
  return db.collection('jokerVisits').doc(groupId + ' ' + jokerId).set({
    group: db.collection('groups').doc(groupId),
    station: db.collection('jokers').doc(jokerId),
    time
  })
}

export function bindLoggedInUser (vm, member, cancelCallback, readyCallback) {
  auth.onAuthStateChanged(loggedInUser => {
    if (loggedInUser) {
      vm.$bind(member, db.collection('users').doc(loggedInUser.uid), { maxRefDepth: 3 })
        .then(readyCallback)
        .catch(cancelCallback)
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
      if (!vm.loggedInOperator || !vm.loggedInOperator.isOperator) {
        vm.$router.replace({ name: 'index' })
      }
    })
  })
}
