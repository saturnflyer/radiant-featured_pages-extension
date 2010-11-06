# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-featured_pages-extension/version"

Gem::Specification.new do |s|
  s.name        = "radiant-featured_pages-extension"
  s.version     = RadiantFeaturedPagesExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jim Gay"]
  s.email       = ["jim@saturnflyer.com"]
  s.homepage    = "http://github.com/saturnflyer/radiant-featured_pages-extension"
  s.summary     = %q{Featured Pages Extension for Radiant CMS}
  s.description = %q{Allows you to provide a featured_date for any page and list it with <r:featured_pages>}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.post_install_message = %{
  Add this to your radiant project with:
    config.gem 'radiant-featured_pages-extension', :version => '#{RadiantFeaturedPagesExtension::VERSION}'
  }
end