<template>
    <div class="container-fluid">
        <div class="container">

            <h2>{{ title }}</h2>
            <p class="lead"></p>

            <div class="row">
                <div class="col">

                    <!-- Navigation -->
                    

                </div>
            </div>

            <div class="row">
                <div class="col">

                    <form id="module-form">
                        <!-- Select layout template file -->
                        <div class="form-group">
                            <label for="exampleInputEmail1">Layout mal</label>
                            <model-select v-model="selected" :options="options" placeholder="- Velg layout mal -"></model-select>
                            <small class="text-muted">Velg malen som skal fordele scenene.</small>
                        </div>

                        <!-- Input template attributes -->

                        <input type="hidden" name="foo" value="bar" />
                        <button id="sendBtn" class="btn btn-primary" type="submit" @click="submitLayout" :disabled="selected.length > 0">Send til layout</button>
                    </form>

                </div>
            </div>
        </div>
    </div>
</template>

<script>
    import { mapState } from 'vuex'
    import {actionResponse} from '../SketchupAPI'

    export default {
        data: function() {
            return {
                title: "Produksjon",
                subtitle: "Generer produksjonstegninger",
                selected: {}
            }
        },
        computed: mapState({
            options: state => state.layout.options
        }),
        methods: {
            submitLayout: function(e){
                e.preventDefault()
                console.log(e)
                console.log(this.selected)

                sketchup.action_response(actionResponse.MOD_LAYOUT_SEND_TO_LAYOUT, JSON.stringify(this.selected))
            }
        },
        mounted: function(){
            // Retrieves layout file options (populatet in vuex store)
            sketchup.load_module_info('production')
        }
    }
</script>