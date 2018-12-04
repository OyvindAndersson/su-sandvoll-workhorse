# Copyright 2016 Trimble Inc
# Licensed under the MIT license

require 'sketchup.rb'

#
# All selected components and groups split into individual Scenes
# Zoom extend on each object in scene
# Rotate view towards Y axis (in example)
# 
#
#

module SandvollEntreprenor
	module WorkHorse

		def self.layout
			puts "Cunt"

			model = Sketchup.active_model
			if model.nil?
				UI.messagebox("Det må være ein aktiv modell for å kjøre denne funksjonen")
				return
			end

			model_path = model.path
			if model_path.empty?
				UI.messagebox("Modellen må være lagret først!")
			end

			# Make prompt for template choice
			template_dir_path = "#{File.expand_path('~')}/AppData/Roaming/SketchUp/SketchUp 2018/LayOut/Templates"
			template_files = Dir[template_dir_path + "/*.layout"]
			template_dir_base_path = ""

			if template_files.length > 0
				# Get only dir path to the templates. We don't want to show that in the selectbox
				template_dir_base_path = File.dirname template_files[0]

				# Extract all file names
				template_files_nameonly = template_files.map { |item| File.basename(item, ".layout")}

				# Get the first item in the array
				default_selection = template_files_nameonly[0]

				# Make the array into a pipe-delimited string, for the selectbox items
				template_files_nameonly_piped = template_files_nameonly.join("|")

				begin
					templateInput = UI.inputbox(["Velg Layout mal"], [default_selection], [template_files_nameonly_piped], "Layout mal")
				rescue ArgumentError => err
					UI.messagebox("Error: " + err)
				end
			end

			puts template_dir_base_path.to_s + templateInput[0].to_s + ".layout"
			#return

			# Create the output path for the layout file, we will name it the same as
    		# the .skp, but append the output paper size.
			dir_path = File.dirname model_path
			file_name = File.basename(model_path, ".skp") + " - "

			# Name on the layout file (based on the SKP file)
			file_name = file_name + ".layout"
			layout_path = File.join(dir_path, file_name) # Path to where the new layout file will be saved
			layout_template_file_path = "#{template_dir_base_path}/#{templateInput[0]}.layout" # Path to the template to use/open

			begin
				self.create_layout_doc(model_path, layout_path, layout_template_file_path)
			
			end

			# Try to send to LayOut directly in newer versions.
			if Sketchup.respond_to?(:send_to_layout) and File.exist?(layout_path)
				sent_to_layout = Sketchup.send_to_layout(layout_path)
			else
				sent_to_layout = false;
			end

		end

		def self.create_layout_doc(skp_file_path, layout_file_path, layout_template_file_path)
			puts "CREATE LAYOUT DOC MOTHERFUCKER"
			puts layout_template_file_path

			# Open selected layout template file
			lo_file = Layout::Document.open(layout_template_file_path)
			page_width = lo_file.page_info.width
			page_height = lo_file.page_info.height

			puts page_width.to_s

			# Create skp model from file path (Using A3) [297 / 25.4, 420 / 25.4]
			bounds_first = Geom::Bounds2d.new(0.5, 0.5, page_width - 1.0, page_height - 2.0)
			bounds = Geom::Bounds2d.new(0.5, 0.5, page_width - 2, page_height - 1)

			begin
				skp_model = Layout::SketchUpModel.new(skp_file_path, bounds_first)
			rescue ArgumentError
				UI.messagebox("Error: Loading SketchUp Model!")
			end

			# Create a new layer for text
			text_layer = lo_file.layers.add("Text", false)

			# Create a new layer for skp models
			skp_layer = lo_file.layers.add("Models", false)

			# Reorder layer -- skp on bottom layer, then text, then default
			lo_file.layers.reorder(skp_layer, 0)
			lo_file.layers.reorder(text_layer, 1)

			#lo_file.page_info.height = height
			#lo_file.page_info.width = width
			lo_file.page_info.display_resolution = Layout::PageInfo::RESOLUTION_HIGH

			num_scenes = skp_model.scenes.length

			if(num_scenes == 1)
				# Add the instance on the first page of the template
				lo_file.add_entity(skp_model, skp_layer, lo_file.pages.first)
			else
				# skip the default scene
				page = lo_file.pages[0]
				1.upto(num_scenes - 1) { |index|
					if(index > 1)
						page = lo_file.pages.add
						# make a new skp model
						skp_model = Layout::SketchUpModel.new(skp_file_path, bounds)
						skp_model.current_scene = index
					end

					begin
						lo_file.add_entity(skp_model, skp_layer, page)
					rescue ArgumentError
						UI.messagebox("Error: Adding SketchUp Model to the LayOut Document!")
					end

					page.name = skp_model.scenes[index]
				}
			end

			begin
				lo_file.save(layout_file_path)
			rescue ArgumentError
				UI.messagebox("Error: Saving Layout Document!")
			end
		end



		# This method creates a simple cube inside of a group in the model.
		def self.create_cube
		  # We need a reference to the currently active model. The SketchUp API
		  # currently only lets you work on the active model. Under Windows there
		  # will be only one model open at a time, but under OS X there might be
		  # multiple models open.
		  #
		  # Beware that if there is no model open under OS X then `active_model`
		  # will return nil. In this example we ignore that for simplicity.
		  model = Sketchup.active_model

		  # Whenever you make changes to the model you must take care to use
		  # `model.start_operation` and `model.commit_operation` to wrap everything
		  # into a single undo step. Otherwise the user risks not being able to
		  # undo everything and she may loose work.
		  #
		  # Making sure your model changes are undoable in a single undo step is a
		  # requirement of the Extension Warehouse submission quality checks.
		  #
		  # Note that the first argument name is a string that will be appended to
		  # the Edit > Undo menu - so make sure you name your operations something
		  # the users can understand.
		  model.start_operation('Create Cube', true)

		  # Creating a group via the API is slightly different from creating a
		  # group via the UI.  Via the UI you create the faces first, then group
		  # them. But with the API you create the group first and then add its
		  # content directly to the group.
		  group = model.active_entities.add_group
		  entities = group.entities

		  # Here we define a set of 3d points to create a 1x1m face. Note that the
		  # internal unit in SketchUp is inches. This means that regardless of the
		  # model unit settings the 3d data is always stored in inches.
		  #
		  # In order to make it easier work with lengths the Numeric class has
		  # been extended with some utility methods that let us write stuff like
		  # `1.m` to represent a meter instead of `39.37007874015748`.
		  points = [
			Geom::Point3d.new(0,   0,   0),
			Geom::Point3d.new(1.m, 0,   0),
			Geom::Point3d.new(1.m, 1.m, 0),
			Geom::Point3d.new(0,   1.m, 0)
		  ]

		  # We pass the points to the `add_face` method and keep the returned
		  # reference to the face as we want to keep working with it.
		  #
		  # Note that normally the orientation (its normal) is a result of the order
		  # of the 3d points you use to create it. The exception is when you create
		  # a face on the ground plane (all points with z == 0) then it will always
		  # be face down.
		  face = entities.add_face(points)

		  # Here we invoke SketchUp's push-pull functionality on the face. But note
		  # that we must use a negative number in order for it to extrude upwards
		  # in the positive direction of the Z-axis. This is because SketchUp
		  # forced this face on the ground place to be face down.
		  face.pushpull(-1.m)

		  # Finally we are done and we close the operation. In production you will
		  # want to catch errors and abort to clean up if your function failed.
		  # But for simplicity we won't do this here.
		  model.commit_operation
		end

		def self.test
			model = Sketchup.active_model
			model.start_operation('Multi-Face pushpull', true)

			selection = model.selection.to_a
			faces = selection.grep(Sketchup::Face)

			faces.each do |face|
				face.pushpull(-2400.mm)
			end

			model.commit_operation
		end


		def self.create_toolbar
			toolbar = UI::Toolbar.new PLUGIN_NAME

			create_cube_cmd = UI::Command.new("Make the Cube") {
				self.layout
			}
			create_cube_cmd.small_icon = ""
			create_cube_cmd.large_icon = ""
			create_cube_cmd.tooltip = "Make an awesome 1x1m cube"
			create_cube_cmd.status_bar_text = "Making a cube"
			create_cube_cmd.menu_text = "Make the cube 1x1"

			toolbar = toolbar.add_item create_cube_cmd
			toolbar.show
		end

		def self.create_menus
			menu = UI.menu('Extensions')
			submenu = menu.add_submenu(PLUGIN_NAME)

			submenu.add_item("Lag boks (Debug)")  {
				self.create_cube
			}

			submenu.add_item("Generer") {
				self.test
			}
		end
		# Here we add a menu item for the extension. Note that we again use a
		# load guard to prevent multiple menu items from accidentally being
		# created.
		unless file_loaded?(__FILE__)
		  self.create_menus
		  self.create_toolbar

		  file_loaded(__FILE__)
		end
	
	end # module WorkHorse
end # module Examples
