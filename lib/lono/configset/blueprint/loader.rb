module Lono::Configset::Blueprint
  class Loader < Lono::Configset::Loader
    def configset_root
      Lono::Finder::Blueprint::Configset.find(@name)
    end
  end
end
