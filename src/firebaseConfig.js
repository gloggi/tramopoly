import firebase from 'firebase/app'
import 'firebase/firestore'
import 'firebase/auth'
import 'firebase/database'
import { calculateCheckpointData } from './business'

const config = {
  apiKey: process.env.VUE_APP_FIREBASE_API_KEY,
  authDomain: process.env.VUE_APP_FIREBASE_AUTH_DOMAIN,
  databaseURL: process.env.VUE_APP_FIREBASE_DATABASE_URL,
  projectId: process.env.VUE_APP_FIREBASE_PROJECT_ID,
  storageBucket: '',
  messagingSenderId: process.env.VUE_APP_FIREBASE_MESSAGING_SENDER_ID
}

firebase.initializeApp(config)
const db = firebase.firestore()

const auth = firebase.auth()
const RecaptchaVerifier = firebase.auth.RecaptchaVerifier

/**
 * Configure how far into the future stationVisits, jokerVisits and mrTChanges are read by default.
 * This should be longer than the duration of the game, currently 12 hours.
 * When the user first loads the page and his device connects to firebase, he will be getting updates for all events
 * until 12 hours later, assuming he keeps his device awake and listening for so long.
 * @type {number} duration in milliseconds
 */
const READ_AHEAD = 24 * 60 * 60000

export const checkpointDB = () => db.collection('checkpoints').where('time', '>', new Date(0)).orderBy('time', 'desc').limit(1)
export const groupsDB = () => db.collection('groups')
export const abteilungenDB = () => db.collection('abteilungen')
export const stationsDB = () => db.collection('stations')
export const jokersDB = () => db.collection('jokers')
export const settingsDB = () => db.collection('settings').doc('settings')
export const stationVisitsDB = (start = new Date(0), end = new Date(new Date().getTime() + READ_AHEAD)) => {
  return db.collection('stationVisits').where('time', '>', start).where('time', '<=', end).orderBy('time')
}
export const jokerVisitsDB = (start = new Date(0), end = new Date(new Date().getTime() + READ_AHEAD)) => {
  return db.collection('jokerVisits').where('time', '>', start).where('time', '<=', end).orderBy('time')
}
export const mrTChangesDB = (start = new Date(0), end = new Date(new Date().getTime() + READ_AHEAD)) => {
  return db.collection('mrTChanges').where('time', '>', start).where('time', '<=', end).orderBy('time')
}
export const usersDB = () => db.collection('users')
export { auth, RecaptchaVerifier }

export function addGroup (groupData, existingGroups) {
  const abteilungId = groupData.abteilung.id
  groupData.abteilung = abteilungenDB().doc(abteilungId)
  const groupId = createUniqueGroupId(abteilungId, existingGroups)
  const groupRef = db.collection('groups').doc(groupId)
  groupRef.set(groupData)
  return groupRef
}

function createUniqueGroupId (abteilungId, existingGroups) {
  const existingGroupIds = existingGroups.map(group => group.id)
  let index = 0
  while (existingGroupIds.includes(abteilungId + index)) index++
  return abteilungId + index
}

export function addUser (uid, userData) {
  if (!uid) return
  return db.collection('users').doc(uid).set(userData)
}

export function setWhatsAppPreference (uid, preference) {
  if (!uid) return
  return db.collection('users').doc(uid).update({ preferWhatsApp: preference })
}

export function setGameEndTime (dateTime) {
  if (!dateTime) return
  return db.collection('settings').doc('settings').update({ gameEnd: dateTime })
}

export function setOperatorGroupAvailable (available) {
  return db.collection('groups').doc('zentrale').update({ active: available })
}

export function changeGroupOperator (abteilungId, operatorId) {
  if (!abteilungId) return
  if (!operatorId) {
    return db.collection('abteilungen').doc(abteilungId).update({ operator: null })
  } else {
    return db.collection('abteilungen').doc(abteilungId).update({ operator: db.collection('users').doc(operatorId) })
  }
}

export function changeUserRole (userId, role) {
  if (!userId) return
  return db.collection('users').doc(userId).update({ role: role })
}

export function setGlobalMessage (type, title, message) {
  return db.collection('settings').doc('settings').update({ message: { type, title, message } })
}

export function setActiveCall (operatorId, callerId) {
  if (!operatorId) return
  return db.collection('users').doc(operatorId).update({ activeCall: callerId ? db.collection('users').doc(callerId) : null })
}

export function addStationVisit (groupId, stationId) {
  if (!groupId || !stationId) return
  const time = new Date()
  return db.collection('stationVisits').doc(time.toLocaleTimeString('de-CH') + ' ' + groupId + ' ' + stationId).set({
    group: db.collection('groups').doc(groupId),
    station: db.collection('stations').doc(stationId),
    time
  })
}

export function addJokerVisit (groupId, jokerId) {
  if (!groupId || !jokerId) return
  const time = new Date()
  return db.collection('jokerVisits').doc(time.toLocaleTimeString('de-CH') + ' ' + groupId + ' ' + jokerId).set({
    group: db.collection('groups').doc(groupId),
    station: db.collection('jokers').doc(jokerId),
    time
  })
}

export function addMrTChange (groupId, mrTChangeData) {
  if (!groupId) return
  const time = new Date()
  return db.collection('mrTChanges').doc(time.toLocaleTimeString('de-CH') + ' ' + groupId).set({
    ...mrTChangeData,
    group: db.collection('groups').doc(groupId),
    time
  })
}

export function setMrTShouldCallOperator (mrTId) {
  if (!mrTId) return
  console.log(mrTId)
  return db.collection('mrTChanges').doc(mrTId).update({ shouldCallOperator: true })
}

export async function createCheckpoint (date) {
  const checkpoint = { ...(await calculateCheckpoint(date)), time: date }
  return db.collection('checkpoints').doc(date.toLocaleTimeString('de-CH')).set(checkpoint)
}

async function calculateCheckpoint (checkpointDate) {
  // Fetch all data up until the checkpoint time
  const groups = await getValueOnce(groupsDB().where('active', '==', true))
  const groupsMap = groups.reduce((map, group) => map.set(group.id, group), new Map())
  const stations = await getValueOnce(stationsDB())
  const stationsMap = stations.reduce((map, station) => map.set(station.id, station), new Map())
  const jokers = await getValueOnce(jokersDB())
  const jokersMap = jokers.reduce((map, joker) => map.set(joker.id, joker), new Map())
  const stationVisits = (await getValueOnce(stationVisitsDB(new Date(0), checkpointDate)))
    .map(stationVisit => ({
      ...stationVisit,
      station: stationsMap.get(stationVisit.station.id),
      group: groupsMap.get(stationVisit.group.id)
    }))
  const jokerVisits = (await getValueOnce(jokerVisitsDB(new Date(0), checkpointDate)))
    .map(jokerVisit => ({
      ...jokerVisit,
      station: jokersMap.get(jokerVisit.station.id),
      group: groupsMap.get(jokerVisit.group.id)
    }))
  const mrTChanges = await getValueOnce(mrTChangesDB(new Date(0), checkpointDate))
  const settings = await getValueOnce(settingsDB())
  // Calculate all scores and ownership at the checkpoint time and return it in a storable format
  return calculateCheckpointData(groups, stationVisits, jokerVisits, mrTChanges, settings, checkpointDate)
}

function getValueOnce (db) {
  return db.get().then(snapshot => {
    if (snapshot.docs) return snapshot.docs.map(entry => ({ id: entry.id, ...entry.data() }))
    if (snapshot.exists) return { id: snapshot.id, ...snapshot.data() }
    return undefined
  })
}

function findUserByPhone (phone) {
  return new Promise(resolve => {
    db.collection('users').where('phone', '==', phone).onSnapshot(snapshot => resolve(snapshot))
  })
}

let latestBindUserByPhonePromise

export async function bindUserByPhone (vm, member, phone) {
  const promise = findUserByPhone(phone)
  latestBindUserByPhonePromise = promise
  const snapshot = await promise
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
