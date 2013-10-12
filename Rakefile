# Configuration
$command = 'rake'

# Globals
$force = false

#Includes
require 'find'

desc "Auto-build documents and auto-scale assets."
task :default do
	$command = 'rake'
	require "./resources/rb/autorake.rb"
end

desc "Auto-build documents from SA export."
task :build do
	$command = 'rake build'
	require "./resources/rb/autorake.rb"
end

desc "Auto-scale images and move to asset bundle."
task :scale do
	$command = 'rake scale'
	require "./resources/rb/autorake.rb"
end

desc "Force auto-rebuild and auto-rescale"
task :force do
	$command = 'rake force'
	require "./resources/rb/autorake.rb"
end

desc "Remove all images from asset bundle"
task :clean do
	require "./resources/rb/clean.rb"
end