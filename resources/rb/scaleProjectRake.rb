##
# Utility to create a scaled copy of an existing Sencha Animator project
#

require 'fileutils'
require 'RMagick'

# make sure project scale percentage is set and valid
if !(defined? $saProjectScalerPercent) then abort 'project scale percentage is undefined' end
if $saProjectScalerPercent == 100 then abort 'nothing to do: project scale percentage is 100' end

# validate source project dir exists
sourceDirName = 'saProject'
if !Dir.exist?(sourceDirName) then abort 'SA project directory is missing' end

# copy source project dir to target project dir
targetDirName = sourceDirName + $saProjectScalerPercent.to_s                # new target dir name
if Dir.exist?(targetDirName) then FileUtils.rm_r(targetDirName) end         # remove existing target dir
FileUtils.cp_r(sourceDirName,targetDirName)                                 # copy source -> target, recursively

# scale all target project files
Dir.glob(targetDirName + '/*.anim') do |relpth|

  # get name of existing project file
  projectFileName = File.basename(relpth)

  # create modified project filename: [original][scalePercent].anim
  outputFileName = projectFileName.chomp(".anim") << $saProjectScalerPercent.to_s << '.anim'

  # scale project file
  system("ruby ../../resources/rb/scaleProject.rb #{targetDirName}/#{projectFileName} #{targetDirName}/#{outputFileName} #{$saProjectScalerPercent}")

  # remove temp copy of original project file
  File.unlink relpth

end

# scale all target assets accordingly
puts "scaling assets to #{$saProjectScalerPercent} percent of original..."
scaleFactor = $saProjectScalerPercent / 100.0
Dir.glob(targetDirName + '/assets/*.png') do |relpth|
  puts relpth
  imglst = Magick::ImageList.new(relpth)
  imglst.scale!(scaleFactor)
  imglst.write(relpth)
end

# remove export directory, if it exists
exportDirName = 'saExport'
if Dir.exist?(exportDirName) then FileUtils.rm_r(exportDirName) end

# done!
puts 'done!'
