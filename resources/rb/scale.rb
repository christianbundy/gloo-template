require 'RMagick'
require 'fileutils'

Dir.glob('saExport/assets/*.png') do |f|
    # Get file name
    fName = File.basename(f)

    # Set asset path
    assetPath = "../../assetBundles/#{$applet}/scaledAssets/"

    # Find last-modified timestamp (if it exists)

    if File.exist?("#{assetPath}100/#{fName}")
        nonExistent = false
        fModified = File.mtime(f)
        assetModified = File.mtime("#{assetPath}100/#{fName}")
    else 
        nonExistent = true
    end

    bigPicture = "#{assetPath}100/#{fName}"
    

    # Compare last-modified timestamps
    if nonExistent || fModified > assetModified || $force
    	# Copy file to asset path, and touch mtime
    	FileUtils.cp f, bigPicture
    	FileUtils.touch(bigPicture)

    	fullSize = Magick::ImageList.new(f)

    	half = fullSize.scale(0.5)
    	half.write("#{assetPath}50/#{fName}")
    	FileUtils.touch("#{assetPath}50/#{fName}")

    	quarter = fullSize.scale(0.25)
    	quarter.write("#{assetPath}25/#{fName}")
    	FileUtils.touch("#{assetPath}25/#{fName}")
        puts "#{$applet}/#{$element}: scale #{fName}"
    end
end
