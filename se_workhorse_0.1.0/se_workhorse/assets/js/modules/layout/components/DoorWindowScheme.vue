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
                            <label for="exampleInputEmail1">Layout mal</label>
                            <select id="templates_selectbox" class="form-control" name="template_file" v-model="selected">
                                <option value="">--</option>
                                <option v-for="option in options" :value="option.value" :key="option.id">
                                    {{ option.text }}
                                </option>
                            </select>
                            <small class="text-muted">Velg malen som skal fordele scenene.</small>
                        </div>

                        <!-- Input template attributes -->
                        <input type="hidden" name="foo" value="bar" />
                        <button id="sendBtn" class="btn btn-primary" type="submit" disabled>Send til layout</button>
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
                title: "Dør og Vinduskjema",
                subtitle: "Generer vinduskjema i en valgt Layout-mal.",
                selected: ''
            }
        },
        computed: mapState({
            options: state => state.layout.options
        }),
        mounted: function(){
            sketchup.load_module_info('production')
        }
    }
</script>