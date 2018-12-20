import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

/**
 * Store module for the Layout module
 */
const layersModule = {
    state: {
        options: []
    },
    mutations: {
        addOptions (state, options) {
            state.options = options
        }
    },
    actions: {
        addOptions ({ commit, state }, options) {
            commit('addOptions', options)
        }
    }
}

/**
 * Configure our store
 */
export const store = new Vuex.Store({
    modules: {
        layers: layersModule
    }
})