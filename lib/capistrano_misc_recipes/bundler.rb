module CapistranoMiscRecipes
  module Bundler
    def bundlify command
      return defined?(Bundler) ? "bundle exec #{command}" : command
    end
  end
end
