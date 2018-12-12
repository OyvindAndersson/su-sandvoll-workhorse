# encoding: utf-8

# Copyright 2016 Trimble Inc
# Licensed under the MIT license
require "pathname"
require 'json'
require 'sketchup.rb'

module SandvollEntreprenor
    module Production

        MENU_LABEL = "Produksjon"
        MODULE_ASSETS = "#{File.join(File.dirname(__FILE__), "assets", "modules", "layout")}".freeze
        
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
                json = get_layout_templates
                dialog.execute_script("window.skp_action('MOD_LAYOUT_TEMPLATE_NAMES','#{json}')")

                # ... do other onload stuff for the interface
            end

            # json_args => [{"name"=>"template_file", "value"=>"Forespørsel"}]
            dialog.add_action_callback("send_to_layout") do |context, json_args|
                args = JSON.parse(json_args)
                puts args
                puts args["template_file"]
            end

        end

        #
        # Retrieve the names of all files stored in LayOuts' template folder.
        #
        def self.get_layout_templates

            # Make prompt for template choice
			template_dir_path = Pathname("#{ENV["HOME"]}/AppData/Roaming/SketchUp/SketchUp 2018/LayOut/Templates")
			template_files = Dir[template_dir_path.to_s + "/*.layout"]

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
			splitscene_cmd.small_icon = "assets/images/scenes_to_layout-01.png"
			splitscene_cmd.large_icon = "assets/images/scenes_to_layout-01.png"
			splitscene_cmd.tooltip = "Send og splitt scener til layout"
			splitscene_cmd.status_bar_text = ""
            splitscene_cmd.menu_text = ""
            
            extension_main_toolbar.add_item splitscene_cmd
        end
    end
end