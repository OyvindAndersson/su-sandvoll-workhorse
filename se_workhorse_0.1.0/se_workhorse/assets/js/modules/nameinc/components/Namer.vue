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
                            <label for="exampleInputEmail1">Skriv inn navn og start teller</label>
                        </div>

                        <div class="row">
                            <div class="col">
                                <div class="form-group">
                                    <label>Fast navn</label>
                                    <input class="form-control" type="text" v-model="baseName">
                                </div>
                            </div>
                            <div class="col">
                                <div class="form-group">
                                    <label>Teller</label>
                                    <input class="form-control" type="number" v-model="startIncrement">
                                </div>
                                
                            </div>
                        </div>

                        <!-- Input template attributes -->
                        <input type="hidden" name="foo" value="bar" />
                        <button id="sendBtn" class="btn btn-primary" type="button" @click="resetNaming">Nullstill til valg</button>
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
                title: "Navngiveren",
                subtitle: "",
                selected: { text: '', value: 0 },
                baseName: "E1N",
                startIncrement: 1
            }
        },
        computed: mapState({
            options: state => state.layers.options
        }),
        mounted: function(){
            sketchup.load_module_info('nameinc')
        },
        methods: {
            resetNaming: function() {
                let jsonDataString = JSON.stringify({ name: this.baseName, startIncrement: this.startIncrement})
                if(sketchup){
                    sketchup.action_response('MOD_NAMEINC_SET_NAME', jsonDataString)
                } else {
                    console.log("Sketchup not defined.")
                }
            }
        }
    }
</script>
