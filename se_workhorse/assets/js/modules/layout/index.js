import Vue from 'vue'
import VueRouter from 'vue-router'

import {skp_init} from './SketchupAPI'
const skp_action = require('./SketchupAPI').skp_action

import Production from './Production.vue'
import DoorWindowScheme from './DoorWindowScheme.vue'
import Quote from './Quote.vue'

Vue.use(VueRouter)
Vue.config.devtools = true

/**
 * Register modules
 */
//Vue.component('production-page', require('./modules/layout/Production.vue').default)

/**
 * Routes
 */
const routes = [
  { path: '/production', component: Production },
  { path: '/doorwindow', component: DoorWindowScheme },
  { path: '/quote', component: Quote }
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
  created: function() {
      try{
        skp_init()
      } catch {
          console.error("Failed to load Sketchup")
      }
      
  }
}).$mount('#app')