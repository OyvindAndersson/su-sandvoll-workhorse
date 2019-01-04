import Vue from 'vue'
import VueRouter from 'vue-router'

import { ModelSelect } from 'vue-search-select'

import Production from './components/Production.vue'
import DoorWindowScheme from './components/DoorWindowScheme.vue'
import Quote from './components/Quote.vue'

import {store} from './store'

/**
 * This module exports all sketchup callable functions
 * This is so we can execute functions from Ruby / native by scoping
 * to the module library export name.
 * See: "webpack.config.js => output.library"
 */
import {skp_init, skp_action} from './SketchupAPI'
export default {
  skp_init,
  skp_action
}

/** 
 * Pre-config VUE 
*/
Vue.use(VueRouter)
Vue.config.devtools = true

/**
 * Globally Register modules
 */
//Vue.component('production-page', require('./modules/layout/Production.vue').default)
Vue.component('model-select', ModelSelect)

/**
 * Routes
 */
const routes = [
  { path: '*', component: Production },
  { path: '/quote', component: Quote },
  { path: '/doorwindow', component: DoorWindowScheme }
]

/**
 * Create instance of the router
 */
const router = new VueRouter({
  routes
})

/**
 * Init app
 */
var app = new Vue({
  router,
  store,
  created: function() {
      try{
        skp_init()
      } catch {
          console.error("Failed to load Sketchup")
      }
      
  }
}).$mount('#app')