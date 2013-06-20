# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano_misc_recipes/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano_misc_recipes"
  spec.version       = CapistranoMiscRecipes::VERSION
  spec.authors       = ["corlinus"]
  spec.email         = ["corlinus@gmail.com\n"]
  spec.description   = %q{misc recipes for capistrano}
  spec.summary       = %q{recipes for capistrano}
  spec.homepage      = "http://github.com/corlinus/capistrano_misc_recipes"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", "> 2.0.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
