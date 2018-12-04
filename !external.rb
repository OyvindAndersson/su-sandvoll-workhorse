SOURCE = File.join(ENV["HOME"], "Source").freeze

 
paths = [
  "C:/Users/oyvind/Documents/GitHub/su-sandvoll-workhorse"
  # "#{SOURCE}/ExampleExtension/src",
  # Add more as needed here...
]

# Un-comment if you want to see any potential loading errors in the Ruby
# Console:
SKETCHUP_CONSOLE.show

paths.each { |path|
  $LOAD_PATH << path
  Dir.glob("#{path}/*.{rb,rbs,rbe}") { |file|
    Sketchup.require(file)
  }
}