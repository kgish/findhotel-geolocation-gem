$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "geolocation/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "geolocation"
  s.version     = Geolocation::VERSION
  s.authors     = ["Kiffin Gish"]
  s.email       = ["kiffin.gish@planet.nl"]
  s.homepage    = "http://gishtech.com"
  s.summary     = "Geolocation gem for Findhotel."
  s.description = "Service for matching location information to IP address."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.2"

  s.add_development_dependency "pg"
end
