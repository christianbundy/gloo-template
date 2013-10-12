#!/usr/bin/env ruby

##
# Sencha Animator project file scaler - command line program
# Flying Rhino - Lowell List - September 2013
# built and tested on Ruby 2.0.0
#

require 'json'

# ------------------ constants ------------------

VERBOSE_OUTPUT = false

# ------------------ misc functions ------------------

# print usage description
def print_usage()
  puts 'usage: ./scaleSAProject inputProject.anim outputProject.anim 25'
  puts '                        ^ input path      ^ output path      ^ scale percentage of original'
end

# ------------------ data modification functions ------------------

# scale scene and root object
def scale_scene(scene, scale)
  if VERBOSE_OUTPUT
    sceneName = scene['config'].has_key?('name') ? scene['config']['name'] : 'default'
    puts 'scaling scene [' + sceneName + ']...'
  end
  scale_object(scene['data'],scale,0)
end

# scale symbol and all its objects
def scale_symbol(symbol, scale)

  if VERBOSE_OUTPUT then puts 'scaling symbol [' + symbol['properties']['symbol-name']['value'] + ']...' end

  # scale symbol itself
  scale_properties(symbol['properties'],scale)

  # process all objects
  if symbol.has_key?('objects')
    symbol['objects'].each do |object|
      scale_object(object,scale,1)
    end
  end

end

# scale object and all its children
def scale_object(object, scale, recursion_depth)

  # get object name, if set
  object_name = (object['properties'].has_key?('object-name')) ? object['properties']['object-name']['value'] : ''
  if VERBOSE_OUTPUT then puts get_depth_padding(recursion_depth) + "scaling object [#{object_name}] type [#{object['type']}]..." end

  # scale
  scale_properties(object['properties'],scale)

  # process keyframes
  if object.has_key?('timelines')
    object['timelines'].each do |timeline_id,keyframe_array|
      if keyframe_array.length > 0
        if VERBOSE_OUTPUT then puts get_depth_padding(recursion_depth+1) + "scaling keyframes for timeline [#{timeline_id}]..." end
        keyframe_array.each do |keyframe|
          scale_keyframe(keyframe,scale,recursion_depth+2)
        end
      end
    end
  end

  # recursively process children objects
  if object.has_key?('children')
    object['children'].each do |child|
      scale_object(child,scale,recursion_depth+1)
    end
  end
  
end

# scale keyframe
def scale_keyframe(keyframe, scale, padding_depth)
  if VERBOSE_OUTPUT then puts get_depth_padding(padding_depth) + "scaling keyframe at [" + keyframe['properties']['keyframe-time']['value'].to_s + ']...' end
  scale_properties(keyframe['properties'], scale)
end

# scale common properties (base object, keyframe)
def scale_properties(properties, scale)

  # scale translation, width, height
  if properties.has_key?('translate3d')
    properties['translate3d']['x'] *= scale
    properties['translate3d']['y'] *= scale
  end
  if properties.has_key?('width')   then properties['width']['value']   *= scale end
  if properties.has_key?('height')  then properties['height']['value']  *= scale end

  # scale object-image
  if properties.has_key?('object-image')
    properties['object-image']['width'] *= scale              # Q: OK to leave these with floating point?
    properties['object-image']['height'] *= scale
  end

  # scale border radius
  if properties.has_key?('border-top-left-radius')      then properties['border-top-left-radius']['value']      *= scale end
  if properties.has_key?('border-top-right-radius')     then properties['border-top-right-radius']['value']     *= scale end
  if properties.has_key?('border-bottom-right-radius')  then properties['border-bottom-right-radius']['value']  *= scale end
  if properties.has_key?('border-bottom-left-radius')   then properties['border-bottom-left-radius']['value']   *= scale end

  # scale border
  if properties.has_key?('border-top')      then properties['border-top']['width']      *= scale end
  if properties.has_key?('border-right')    then properties['border-right']['width']    *= scale end
  if properties.has_key?('border-bottom')   then properties['border-bottom']['width']   *= scale end
  if properties.has_key?('border-left')     then properties['border-left']['width']     *= scale end

  # scale text modifiers
  if properties.has_key?('font-size')       then properties['font-size']['value']       *= scale end
  if properties.has_key?('text-stroke')     then properties['text-stroke']['width']     *= scale end
  if properties.has_key?('letter-spacing')  then properties['letter-spacing']['value']  *= scale end
  if properties.has_key?('word-spacing')    then properties['word-spacing']['value']    *= scale end
  if properties.has_key?('text-indent')     then properties['text-indent']['value']     *= scale end
  if properties.has_key?('text-shadow')
    properties['text-shadow']['x_offset'] *= scale
    properties['text-shadow']['y_offset'] *= scale
    properties['text-shadow']['blur_radius'] *= scale
  end

end

# returns the appropriate number of white spaces
def get_depth_padding(depth)
  return sprintf("%*s",depth*2,"")
end

# ------------------ main program ------------------

# process command line arguments
if ARGV.length != 3
  print_usage()
  abort 'incorrect number of command line parameters'
end
inputFilePath   = ARGV[0]
outputFilePath  = ARGV[1]
scalePercentage = ARGV[2]
if !(File.exists?(inputFilePath)) # validate file existence
  print_usage()
  abort 'Sencha Animator project file does not exist: ' << inputFilePath
end
if !scalePercentage.match(/^[0-9]+$/)
  print_usage()
  abort 'scale percentage must be a positive integer'
end

# begin processing
puts 'scaling ' << inputFilePath << ' to ' << scalePercentage << ' percent of original...'

# read input file into a string
f = File.open(inputFilePath)
fileData = f.gets()
f.close

# create file data hash
fileDataHash = JSON.parse(fileData) # convert from JSON to Hash

# validate file version
if fileDataHash['fileVersion'] != 7
  abort "unrecognized Sencha Animator project file version: #{fileDataHash['fileVersion']}"
end

# modify data
scaleFactor = scalePercentage.to_i / 100.0
if VERBOSE_OUTPUT then puts "scale factor is #{scaleFactor}" end
fileDataHash['scenes'].each do |scene| # scale all scenes and objects therein
  scale_scene(scene,scaleFactor)
end
fileDataHash['symbols']['symbols'].each do |symbol| # scale all symbols and objects therein
  scale_symbol(symbol,scaleFactor)
end
fileDataHash['projectProperties']['project-height']['value'] *= scaleFactor
fileDataHash['projectProperties']['project-width']['value'] *= scaleFactor

# check if output file exists
if File.exists?(outputFilePath)
  if VERBOSE_OUTPUT then puts "overwriting #{outputFilePath}..." end
end

# write result to output file
f = File.open(outputFilePath, 'w')
f.print fileDataHash.to_json() # convert from Hash to JSON
f.close

# done with processing
puts 'done!'
