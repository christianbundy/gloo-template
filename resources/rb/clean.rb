FileList['./assetBundles/**/*.png'].each { |path|
	File.delete(path)
}