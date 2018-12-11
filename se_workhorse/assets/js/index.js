import Vue from 'vue'
import VueRouter from 'vue-router'

import Production from './module_production/Production.vue'

Vue.use(VueRouter)
Vue.config.devtools = true

const Bar = { template: '<div>Testing testing</div>'}

/**
 * Routes
 */
const routes = [
  { path: '/foo', component: Production},
  { path: '/bar', component: Bar}
]

/**
 * Register modules
 */
Vue.component('production-page', require('./module_production/Production.vue').default)

const router = new VueRouter({
  routes
})

/**
 * Init app
 */
var app = new Vue({
  router
}).$mount('#app')