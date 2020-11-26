# encoding: utf-8

# Copyright 2016 Trimble Inc
# Licensed under the MIT license
require "pathname"
require 'json'
require 'sketchup.rb'

module SandvollEntreprenor
    module Layers

        MENU_LABEL = "Layers"
        MODULE_ASSETS = "#{File.join(File.dirname(__FILE__), "..", "..", "assets", "modules", "layers")}".freeze
        
        #
        # Spawn the HTML dialog interface
        #
        def self.show_dialog
            puts "SandvollEntreprenor::Layers.show_dialog"

            # Get path to index file of the dialog
            file_path = Pathname("#{MODULE_ASSETS}/index.html")
            unless file_path.exist?
                UI.messagebox("Error! Failed to load dialog file at: '#{file_path.to_s}'")
                return
            end

            dialog = UI::HtmlDialog.new({
                :dialog_title => "Layer verktøy",
                :scrollable => true,
                :min_width => 450,
                :min_height => 800,
                :max_width =>1000,
                :max_height => 1000,
                :top => 100,
                :left => 500,
                :style => UI::HtmlDialog::STYLE_DIALOG
            })
            dialog.set_file(file_path.to_s)

            # Add callbacks
            self.setup_js_callbacks(dialog)

            # Center and show dialog
            #dialog.center
            dialog.show
        end

        #
        # Setup JS callbacks for the HTML Dialog interface
        #
        def self.setup_js_callbacks(dialog)

            # When document loads
            dialog.add_action_callback("onload") do |context|
            end

            # After module-sepcific frontend component loads
            dialog.add_action_callback("load_module_info") do |context, module_name|
                puts "loading module info for #{module_name}"

                model = Sketchup.active_model
                layers = model.layers
                layer_names = layers.map{|layer| layer.name.strip}
                @layer_names = layer_names.to_json

                # Get all layer-names over to our frontend
                dialog.execute_script("SKPClientLib.skp_action('MOD_LAYERS_NAMES','#{layer_names}')")
            end

            # json_args => [{"name"=>"template_file", "value"=>"Forespørsel"}]
            dialog.add_action_callback("action_response") do |context, action, values|
                args = JSON.parse(values)
                puts action
                puts args

                case action
                when 'MOD_LAYERS_SET_SELECTED_TO_LAYER'
                    handle_set_selected_to_layer args["text"]
                else
                    puts "Action handler not implemented"
                end
            end

        end

        #
        # Handler for action response: MOD_LAYERS_SET_SELECTED_TO_LAYER
        #
        def self.handle_set_selected_to_layer(layername)
            puts layername

            model = Sketchup.active_model
            layers = model.layers

            if(layers[layername])
                the_layer = layers[layername]

                # start moving selection to layer
                model.start_operation('Set selection to layer', true)

                selection = model.selection
                selection.each { |entity| entity.layer = the_layer }

                # End operation
                model.commit_operation

            else
                UI.messagebox("Layer not found")
                return false
            end
        end

        #
        # Create SKP menus' for this module
        #
        def self.create_menus(submenu)
            # Check if extensions' menu item has been passed in
            unless submenu.nil?

                # Add submenu for this module
                submenu.add_item(MENU_LABEL) {
                    UI.messagebox("Layers module")
                }
            end
        end

        #
        # Create SKP toolbars related to this module
        #
        def self.create_toolbar(extension_main_toolbar)
            cmd = UI::Command.new("Layer verktøy") {
				self.show_dialog
			}
			#cmd.small_icon = "assets/images/scenes_to_layout-01.png"
			#cmd.large_icon = "assets/images/scenes_to_layout-01.png"
			cmd.tooltip = "Layer verktøy"
			cmd.status_bar_text = ""
            cmd.menu_text = ""
            
            extension_main_toolbar.add_item cmd
        end
    end
end