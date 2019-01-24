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
export const mrTChangesDB = db.collection('mrTChanges').where('time', '>', new Date(0)).orderBy('time')
export const usersDB = db.collection('users')
export { auth, RecaptchaVerifier }

export function addGroup (groupData, existingGroups) {
  let abteilungId = groupData.abteilung.id
  groupData.abteilung = abteilungenDB.doc(abteilungId)
  let groupId = createUniqueGroupId(abteilungId, existingGroups)
  let groupRef = db.collection('groups').doc(groupId)
  groupRef.set(groupData)
  return groupRef
}

function createUniqueGroupId (abteilungId, existingGroups) {
  let existingGroupIds = existingGroups.map(group => group.id)
  let index = 0
  while (existingGroupIds.includes(abteilungId + index)) index++
  return abteilungId + index
}

export function addUser (uid, userData) {
  if (!uid) return
  return db.collection('users').doc(uid).set(userData)
}

export function setGameEndTime (dateTime) {
  if (!dateTime) return
  return db.collection('settings').doc('settings').update({ 'gameEnd': dateTime })
}

export function setOperatorGroupAvailable (available) {
  return db.collection('groups').doc('zentrale').update({ active: available })
}

export function changeGroupOperator (abteilungId, operatorId) {
  if (!abteilungId) return
  if (!operatorId) {
    return db.collection('abteilungen').doc(abteilungId).update({ 'operator': null })
  } else {
    return db.collection('abteilungen').doc(abteilungId).update({ 'operator': db.collection('users').doc(operatorId) })
  }
}

export function changeUserRole (userId, role) {
  if (!userId) return
  return db.collection('users').doc(userId).update({ 'role': role })
}

export function setGlobalMessage (type, title, message) {
  return db.collection('settings').doc('settings').update({ 'message': { type, title, message } })
}

export function setActiveCall (operatorId, callerId) {
  if (!operatorId) return
  return db.collection('users').doc(operatorId).update({ 'activeCall': callerId ? db.collection('users').doc(callerId) : null })
}

export function addStationVisit (groupId, stationId) {
  if (!groupId || !stationId) return
  let time = new Date()
  return db.collection('stationVisits').doc(time.toLocaleTimeString('de-CH') + ' ' + groupId + ' ' + stationId).set({
    group: db.collection('groups').doc(groupId),
    station: db.collection('stations').doc(stationId),
    time
  })
}

export function addJokerVisit (groupId, jokerId) {
  if (!groupId || !jokerId) return
  let time = new Date()
  return db.collection('jokerVisits').doc(time.toLocaleTimeString('de-CH') + ' ' + groupId + ' ' + jokerId).set({
    group: db.collection('groups').doc(groupId),
    station: db.collection('jokers').doc(jokerId),
    time
  })
}

export function addMrTChange (groupId, mrTChangeData) {
  if (!groupId) return
  let time = new Date()
  return db.collection('mrTChanges').doc(time.toLocaleTimeString('de-CH') + ' ' + groupId).set({
    ...mrTChangeData,
    group: db.collection('groups').doc(groupId),
    time
  })
}

function findUserByPhone (phone) {
  return new Promise(resolve => {
    db.collection('users').where('phone', '==', phone).onSnapshot(snapshot => resolve(snapshot))
  })
}

let latestBindUserByPhonePromise

export async function bindUserByPhone (vm, member, phone) {
  let promise = findUserByPhone(phone)
  latestBindUserByPhonePromise = promise
  let snapshot = await promise
  if (latestBindUserByPhonePromise === promise) {
    if (!snapshot.empty) {
      vm.$bind(member, db.collection('users').doc(snapshot.docs[0].id))
    } else if (vm._firestoreUnbinds[member]) {
      vm.$unbind(member)
      vm[member] = null
    }
  }
}

export function bindUserById (vm, member, uid) {
  if (uid) {
    return vm.$bind(member, db.collection('users').doc(uid))
  } else if (vm._firestoreUnbinds[member]) {
    vm.$unbind(member)
    vm[member] = null
  }
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

export function requireAuth (to, from, next, readyCallbackGenerator) {
  auth.onAuthStateChanged(user => {
    if (!user) {
      return next('/login')
    }
    next(vm => {
      bindLoggedInUser(vm, 'loggedInUser', null, readyCallbackGenerator(vm))
    })
  })
}

export function requireOperator (to, from, next) {
  next(vm => {
    bindLoggedInUser(vm, 'loggedInOperator', null, () => {
      if (!vm.loggedInOperator || !(vm.loggedInOperator.role === 'operator' || vm.loggedInOperator.role === 'admin')) {
        vm.$router.replace({ name: 'index' })
      }
    })
  })
}

export function requireAdmin (to, from, next) {
  next(vm => {
    bindLoggedInUser(vm, 'loggedInAdmin', null, () => {
      if (!vm.loggedInOperator || !vm.loggedInOperator.role === 'admin') {
        vm.$router.replace({ name: 'index' })
      }
    })
  })
}
