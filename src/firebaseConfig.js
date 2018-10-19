import Vue from 'vue'
import VueFire from 'vuefire'
import firebase from 'firebase/app'

Vue.use(VueFire)

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

export const groupsRef = db.ref(`${year}/groups`)
export { auth } from 'firebase'
