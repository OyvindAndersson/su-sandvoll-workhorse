<template>
    <div class="container-fluid">
        <div class="container">

            <h2>{{ title }}</h2>
            <p class="lead">{{ subtitle }}</p>

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
                            <label for="exampleInputEmail1">Velg layer</label>
                            <model-select v-model="selected" :options="options" placeholder="- Velg layer -"></model-select>
                            
                            <small class="text-muted">Trykk i søkefeltet å begynn å skriv for å filtrere</small>
                        </div>

                        <!-- Input template attributes -->
                        <input type="hidden" name="foo" value="bar" />
                        <button id="sendBtn" class="btn btn-primary" type="button" @click="skpSetToLayer">Angi layer for valgt geometri</button>
                        <button id="sendBtn" class="btn btn-primary" type="button">xxxxxx</button>
                    </form>

                </div>
            </div>
        </div>
    </div>
</template>

<script>
    import { mapState } from 'vuex'

    export default {
        data: function() {
            return {
                title: "Layerverktøy",
                subtitle: "",
                selected: { text: '', value: 0 }
            }
        },
        computed: mapState({
            options: state => state.layers.options
        }),
        mounted: function(){
            sketchup.load_module_info('layers')
        },
        methods: {
            skpSetToLayer: function() {
                let selection = JSON.stringify(this.selected)
                if(sketchup){
                    sketchup.action_response('MOD_LAYERS_SET_SELECTED_TO_LAYER', selection)
                } else {
                    console.log("Sketchup not defined.")
                }
            }
        }
    }
</script>
