# encoding: utf-8

# Copyright 2016 Trimble Inc
# Licensed under the MIT license
require "pathname"
require 'json'
require 'sketchup.rb'

module SandvollEntreprenor
    module LayoutTools

        MENU_LABEL = "Produksjon"
        MODULE_ASSETS = "#{File.join(File.dirname(__FILE__), "..", "..", "assets", "modules", "layout")}".freeze

        @@layout_tpl_files = []
        
        #
        # Spawn the HTML dialog interface
        #
        def self.show_dialog
            puts "SandvollEntreprenor::Production.show_dialog"

            # Get path to index file of the dialog
            file_path = Pathname("#{MODULE_ASSETS}/index.html")
            unless file_path.exist?
                UI.messagebox("Error! Failed to load dialog file at: '#{file_path.to_s}'")
                return
            end

            dialog = UI::HtmlDialog.new({
                :dialog_title => "Split-scene til Layout",
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
                # Send the layout template file-names to the interface
                #json = get_layout_templates

                #dialog.execute_script("SKPClientLib.skp_action('MOD_LAYOUT_TEMPLATE_NAMES','#{json}')")

                # ... do other onload stuff for the interface
            end

            dialog.add_action_callback("load_module_info") do |context, module_name|

                puts "loading module info for #{module_name}"
                # Send the layout template file-names to the interface
                json = get_layout_templates

                dialog.execute_script("SKPClientLib.skp_action('MOD_LAYOUT_TEMPLATE_NAMES','#{json}')")
            end

            # json_args => [{"name"=>"template_file", "value"=>"Forespørsel"}]
            dialog.add_action_callback("action_response") do |context, action, values|
                args = JSON.parse(values)
                puts action
                puts args

                case action
                when 'MOD_LAYOUT_SEND_TO_LAYOUT'
                    _tplFile = @@layout_tpl_files[args['value']]
                    handle_send_to_layout(_tplFile, args)

                else
                    puts "Action handler not implemented"
                end
            end

            # json_args => [{"name"=>"template_file", "value"=>"Forespørsel"}]
            dialog.add_action_callback("send_to_layout") do |context, json_args|
                args = JSON.parse(json_args)
                puts args
                puts args["template_file"]
            end

        end

        #
        #   Entry point to send model/scenes to layout
        #
        def self.handle_send_to_layout(tpl_file, options)

            model = Sketchup.active_model
			if model.nil?
				UI.messagebox("Det må være ein aktiv modell for å kjøre denne funksjonen")
				return
			end

			model_path = Pathname(model.path)
			unless model_path.exist?
                UI.messagebox("Modellen må være lagret først!")
                return
            end
            
            # Create the output path for the layout file, we will name it the same as
    		# the .skp, but append the output paper size.
			dir_path = File.dirname model_path
			file_name = File.basename(model_path, ".skp") + ".layout"
            layout_filename = model_path.dirname + file_name

            begin
				self.create_layout_file(tpl_file, layout_filename, model_path.to_s)
			end
            
            # Try to send the newly created file to LayOut directly, in newer versions.
			if Sketchup.respond_to?(:send_to_layout) and File.exist?(layout_filename)
				sent_to_layout = Sketchup.send_to_layout(layout_filename.to_s)
			else
				sent_to_layout = false;
			end
        end

        #
        #   Handles creating the actual layout file, and splitting up scenes
        #
        def self.create_layout_file(tpl_file, layout_filename, model_path)
            # Open selected layout template file
			begin
				lo_file = Layout::Document.open(tpl_file) # FAIL
			rescue ArgumentError => err
				UI.messagebox("Error: Opening Layout template file from: '#{tpl_file}' - '#{err}'")
				puts "Error: Opening Layout template file from: '#{tpl_file}' - '#{err}'"
			end
			page_width = lo_file.page_info.width
            page_height = lo_file.page_info.height
            
            # Create skp model from file path (Using A3) [297 / 25.4, 420 / 25.4]
			bounds_first = Geom::Bounds2d.new(0.5, 0.5, page_width - 1.0, page_height - 2.0)
			bounds = bounds_first

			# Load instance of the target SKP file
			begin
				skp_model = Layout::SketchUpModel.new(model_path, bounds_first)
			rescue ArgumentError
				UI.messagebox("Error: Loading SketchUp Model!")
            end
            
            # Create a new layer for text and create a new layer for skp models
			text_layer = lo_file.layers.add("Text", false)
            skp_layer = lo_file.layers.add("Models", false)
            
			# Reorder layer -- skp on bottom layer, then text, then default
			lo_file.layers.reorder(skp_layer, 0)
            lo_file.layers.reorder(text_layer, 1)
            
			# Set layout page properties
			lo_file.page_info.display_resolution = Layout::PageInfo::RESOLUTION_HIGH

			# Get the number of scenes in the loaded SKP file
            num_scenes = skp_model.scenes.length
            
            if(num_scenes == 1)
				# Add the instance on the first page of the template
				lo_file.add_entity(skp_model, skp_layer, lo_file.pages.first)
			else
				# skip the default scene
				page = lo_file.pages[0]

				# Loop N scenes and distribute the scenes onto individual pages.
				1.upto(num_scenes - 1) { |index|

					# skp_model is already set with an instance, retrieved before looping here.
					# therefore we don't need to recreate it on the first loop.
					if(index > 1)
						page = lo_file.pages.add
						# make a new skp model instance (for each page)
						skp_model = Layout::SketchUpModel.new(model_path, bounds)
						skp_model.current_scene = index
					end

					# Add the skp model to the skp layer, on the current page in the loop
					begin
						lo_file.add_entity(skp_model, skp_layer, page)
					rescue ArgumentError => err
						UI.messagebox("Error: Adding SketchUp Model to the LayOut Document! : #{err}")
					end

					page.name = skp_model.scenes[index]
				}
            end
            
            begin
                puts "Saving layout file to: #{layout_filename}"
				lo_file.save(layout_filename.to_s)
			rescue ArgumentError
                UI.messagebox("Error: Saving Layout Document!")
                return
            end
        end

        #
        # Retrieve the names of all files stored in LayOuts' template folder.
        #
        def self.get_layout_templates

            # Make prompt for template choice
			template_dir_path = Pathname("#{ENV["HOME"]}/AppData/Roaming/SketchUp/SketchUp 2018/LayOut/Templates")
			template_files = Dir[template_dir_path.to_s + "/*.layout"].reject{|file| file.include? "Backup"}

            @@layout_tpl_files = template_files
            puts @@layout_tpl_files

			if template_files.length > 0
				# Extract all file names
                template_files = template_files.reject{|file| file.include? "Backup"}.collect{|file| File.basename(file.to_s, ".layout")}
            end

            return template_files.to_json
        end

        #
        # Create menus' for this module
        #
        def self.create_menus(submenu)
            # Check if extensions' menu item has been passed in
            unless submenu.nil?

                # Add submenu for this module
                submenu.add_item(MENU_LABEL) {
                    UI.messagebox("Produksjon")
                }
            end
        end

        #
        # Create toolbars related to this module
        #
        def self.create_toolbar(extension_main_toolbar)
            splitscene_cmd = UI::Command.new("Split-scene til Layout") {
				self.show_dialog
			}
			splitscene_cmd.small_icon = "../../assets/images/scenes_to_layout-01.png"
			splitscene_cmd.large_icon = "../../assets/images/scenes_to_layout-01.png"
			splitscene_cmd.tooltip = "Send og splitt scener til layout"
			splitscene_cmd.status_bar_text = ""
            splitscene_cmd.menu_text = ""
            
            extension_main_toolbar.add_item splitscene_cmd
        end
    end
end