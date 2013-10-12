# Gloo Applets

Repository for building Gloo elements from Sencha Animator Projects.

## Installation

  1. Download [Sencha Animator 1.5](http://www.sencha.com/products/animator/)
  2. Install the Rake, RMagick, and FileUtils gems: `gem install rake rmagick fileutils`
  3. Clone this repository: `git clone https://github.com/lowell-list/Gloo-Applets.git` 

## Usage

  1. Create/modify a Sencha Animator project, then save **and** export.
    1. Sencha Animator projects should be *saved* in appletName/element/saProject.
    2. Sencha Animator projects should be *exported* in appletName/element/saExport.
  2. When projects change, run `rake` to selectively build documents and scale PNG assets.
    * `rake` will build and scale.
    * `rake build` will build, but won't scale.
    * `rake scale` will scale, but won't build.
    * `rake force` will build and scale, ignoring a check of the 'Last-Modified' timestamp.
    * `rake force_build` will build only, ignoring a check of the 'Last-Modified' timestamp.
    * `rake scale_project` will create a scaled copy of the saProject directory
  3. Upload to Gloo!
    * Upload the contents of `glooProduction.html` to the Element API Sandbox.
    * Compress assetBundles/appletName and upload to Gloo as appletName.zip

