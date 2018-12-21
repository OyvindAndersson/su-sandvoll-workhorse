require 'sketchup.rb'
require 'extensions.rb'
require 'langhandler.rb'

module SandvollEntreprenor
	module WorkHorse
		VERSION = "0.0.1.r2"
		PLUGIN = self
		PLUGIN_NAME = "Sandvoll Entreprenor".freeze

		if Sketchup.version.to_i >= 16
			ext = SketchupExtension.new(PLUGIN_NAME, (File.join(File.dirname(__FILE__), "se_workhorse", "main")))
			ext.description = "Sandvoll Entreprenør sine tools, yo"
			ext.version = VERSION
			ext.creator = "sandvoll.entreprenor.as"
			ext.copyright = "2018, Sandvoll Entreprenør AS. All rights reserved."
			Sketchup.register_extension(ext, true)
		else
			UI.messagebox("Sketchup 2016 or greater is required to use SE")
		end

		# Reload extension by running this method from the Ruby Console:
		#   SandvollEntreprenor::WorkHorse.reload
		def self.reload
			original_verbose = $VERBOSE
			$VERBOSE = nil
			pattern = File.join(__dir__, '**/**/*.rb')
			Dir.glob(pattern).each { |file|
				# Cannot use `Sketchup.load` because its an alias for `Sketchup.require`.
				load file
			}.size
		ensure
			$VERBOSE = original_verbose
		end
	end
end