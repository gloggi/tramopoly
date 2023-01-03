import Vue from "vue";
import App from "./App";
import router from "./router.js";
import Buefy from "buefy";
import { firestorePlugin } from "vuefire";

Vue.use(Buefy);
Vue.use(firestorePlugin);

Vue.config.productionTip = false;

/* eslint-disable no-new */
new Vue({
  el: "#app",
  router,
  render: (h) => h(App),
});
