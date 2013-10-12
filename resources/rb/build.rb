require 'fileutils'

# Find last-modified timestamp
projectModified = File.mtime('saExport/index.html')
indexModified = File.exist?('index.html') ? File.mtime('index.html') : Time.at(0)

# Compare last-modified timestamps
if projectModified > indexModified || $force

	# modify stage margin if SA project scaler percentage is set
	if (defined? $saProjectScalerPercent) && ($saProjectScalerPercent != 100)
		$stageMargin = ($stageMargin.to_i * ($saProjectScalerPercent / 100.0)).to_s
		puts "#{$applet}/#{$element}: modified stage margin is #{$stageMargin}"
	end

	# Run PHP converter to create glooProduction.html
	system("php ../../resources/php/converter.php '../../#{$applet}/#{$element}/saExport/index.html' #{$orgAssets}/ #{$applet}/scaledAssets/scaleDir/ #{$scaleMode} #{$stageMargin} > glooProduction.html")
	puts "#{$applet}/#{$element}: build glooProduction.html"

	# Add custom code to glooProduction
	custom = File.read("custom.html")
	File.open("glooProduction.html", "a") do |f|
		f.write(custom)
		f.close()
	end

	# Load new Gloo file
	gloo = File.read("glooProduction.html")

	# String replace $orgAssets with dev URL.	
	File.open("glooDevelopment.html", "w") do |f|
		dev = gloo.gsub $orgAssets, "http://gloo.fraboom.com/assetBundles"
		f.write(dev)
		f.close()
	end

	puts "#{$applet}/#{$element}: build glooDevelopment.html"

	header = File.read("../../resources/html/header.html")
	footer = File.read("../../resources/html/footer.html")
	File.open("index.html", "w") do |f|
		f.write(header)
		f.write(gloo)
		f.write(footer)
		f.close()
	end
	puts "#{$applet}/#{$element}: build index.html"
	
end
