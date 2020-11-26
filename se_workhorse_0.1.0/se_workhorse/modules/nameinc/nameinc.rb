# encoding: utf-8

# Copyright 2016 Trimble Inc
# Licensed under the MIT license
require "pathname"
require 'json'
require 'sketchup.rb'

module SandvollEntreprenor
    module NameInc

        MENU_LABEL = "Navngiver"
        MODULE_ASSETS = "#{File.join(File.dirname(__FILE__), "..", "..", "assets", "modules", "nameinc")}".freeze

        @basename = ""
        @current_increment = 0
        @start_increment = 0


        def self.increment()
            @current_increment += 1
        end

        def self.resetToIncrement(value)
            @start_increment = value
            @current_increment = value
        end

        #
        # Check if an object is selected. Isolate it in a new scene
        # with the basename + current increment, then increment the
        # counter for the next.
        #
        def self.create_scene_and_increment()
            model = Sketchup.active_model
            selected_model = model.selection
            curPage = model.pages.selected_page
            entities = model.entities

            # TODO: Check if page already exists

            page_counter = 0
            page_index = 0
            model.pages.each{|page, index|
                if page.name == (@basename + @current_increment.to_s)

                    result = UI.messagebox('Scenen "'+@basename + @current_increment.to_s+'" eksisterer allerede. Vil du slette den gamle og fortsette?', MB_YESNO)
                    if result == IDNO
                        return
                    else
                        page_index = page_counter
                        model.pages.erase(page)
                        break
                    end
                end

                page_counter += 1
            }

            # Add the new page
            new_page = nil

            if page_index != 0
                new_page = model.pages.add(@basename + @current_increment.to_s, 511, page_index)
            else
                new_page = model.pages.add(@basename + @current_increment.to_s)
            end

            # Hide rest of the model entities
            entities.each { |entity| 
               if entity.kind_of? Sketchup::Drawingelement
                    new_page.set_drawingelement_visibility(entity, false)
               end
            }

            # Show selected model entities only
            selected_model.each { |entity|
                if entity.kind_of? Sketchup::Drawingelement
                    new_page.set_drawingelement_visibility(entity, true)
                end
            }
            
            # Update the view
            first_selection = selected_model.first

            #
            # Calculate which direction we should face the camera
            #
            unity = Geom::Vector3d.new(0, 1, 0)
            unitx = Geom::Vector3d.new(1, 0, 0)
            local_y = first_selection.transformation.yaxis
            local_x = first_selection.transformation.xaxis

            center_point = first_selection.bounds.center

            # Front view when local is aligned to world
            if local_y.samedirection?(unity) && local_x.samedirection?(unitx)
                eye = Geom::Point3d.new(center_point.offset(Geom::Vector3d.new(0,-100,0)))
            # Left view when local +y aligned to world +x
            elsif local_y.samedirection?(unitx) && local_x.parallel?(unity)
                eye = Geom::Point3d.new(center_point.offset(Geom::Vector3d.new(-100,0,0)))
            # Right view when aligned to world Y
            elsif local_x.samedirection?(unity) && local_y.parallel?(unitx)
                eye = Geom::Point3d.new(center_point.offset(Geom::Vector3d.new(100,0,0)))
            # Back view
            else
                eye = Geom::Point3d.new(center_point.offset(Geom::Vector3d.new(0,100,0)))
            end

            # Set camera position and target
            camera = new_page.camera
            camera.perspective = false
            camera.set(eye, center_point, Z_AXIS)

            view = model.active_view
            view.zoom_extents


            self.increment

            Sketchup.status_text = "Next name: " + @basename + @current_increment.to_s

            Sketchup.active_model.pages.selected_page = curPage

        end

        #
        # Spawn the HTML dialog interface
        #
        def self.show_dialog
            puts "SandvollEntreprenor::NameInc.show_dialog"

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

                # model = Sketchup.active_model

                # dialog.execute_script("SKPClientLib.skp_action('MOD_LAYERS_NAMES','#{layer_names}')")
            end

            # json_args => [{"name"=>"template_file", "value"=>"Forespørsel"}]
            dialog.add_action_callback("action_response") do |context, action, values|
                args = JSON.parse(values)
                #puts action
                #puts args

                case action
                when 'MOD_NAMEINC_SET_NAME'
                    @basename = args["name"]
                    self.resetToIncrement(args["startIncrement"].to_i)

                    #puts @basename
                    #puts @start_increment

                    self.activate_tool

                else
                    puts "Action handler not implemented"
                end
            end

        end

        #
        # Create SKP menus' for this module
        #
        def self.create_menus(submenu)
            # Check if extensions' menu item has been passed in
            unless submenu.nil?

                # Add submenu for this module
                submenu.add_item(MENU_LABEL + " Meny") {
                    self.show_dialog
                }

                submenu.add_item(MENU_LABEL + " Tool") {
                    #self.activate_tool

                    self.create_scene_and_increment()
                }
            end
        end

        #
        # Create SKP toolbars related to this module
        #
        def self.create_toolbar(extension_main_toolbar)
            cmd = UI::Command.new("Navngiveren") {
				self.show_dialog
			}
			#cmd.small_icon = "assets/images/scenes_to_layout-01.png"
			#cmd.large_icon = "assets/images/scenes_to_layout-01.png"
			cmd.tooltip = "Navngiver verktøy"
			cmd.status_bar_text = ""
            cmd.menu_text = ""
            
            extension_main_toolbar.add_item cmd
        end

        def self.activate_tool
            #nt = NameIncTool.new
            #nt.setCurrentIncrement @current_increment
            #nt.setBaseName @basename
            #Sketchup.active_model.select_tool(nt)
        end

        #-----------------------------------------------------------------------------
        # The tool class that names
        # Awesome sauce tool in the face
        #
        #
        class NameIncTool

            def setCurrentIncrement(value)
                @current_increment = value
            end

            def setBaseName(value)
                @basename = value
            end

            # 
            # Activate tool
            #
            def activate

                update_ui
            end

            #
            # Deactivate tool
            #
            def deactivate(view)
                view.invalidate
            end

            # Tools can be temporarily suspended and resumed. One example of this is
            # when the user uses the Orbit tool by pressing the middle mouse button.
            # In order to make sure we update our statusbar text and custom viewport
            # drawing we need to do that here.
            def resume(view)
                update_ui
                view.invalidate
            end

            #
            # 0: The user canceled the current operation by hitting the escape key.
            # 1: The user re-selected the same tool from the toolbar or menu.
            # 2: The user did an undo while the tool was active.
            def onCancel(reason, view)
                reset_tool
                view.invalidate
            end

             # When the user clicks in the viewport we want to create edges based on
            # the input points we have collected.
            def onLButtonDown(flags, x, y, view)
                
                
                # As always we want to update the statusbar text and view.
                update_ui
                view.invalidate
            end

            # Here we have hard coded a special ID for the pencil cursor in SketchUp.
            # Normally you would use `UI.create_cursor(cursor_path, 0, 0)` instead
            # with your own custom cursor bitmap:
            #
            #   CURSOR_PENCIL = UI.create_cursor(cursor_path, 0, 0)
            CURSOR_PENCIL = 632
            def onSetCursor
                # Note that `onSetCursor` is called frequently so you should not do much
                # work here. At most you switch between different cursors representing
                # the state of the tool.
                UI.set_cursor(CURSOR_PENCIL)
            end

            def update_ui
                Sketchup.status_text = 'Next name: ' + @basename + @current_increment.to_s
            end

            def reset_tool
                update_ui
            end

        end
    end
end