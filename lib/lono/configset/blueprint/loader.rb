module Lono::Configset::Blueprint
  class Loader < Lono::Configset::Loader
    def configset_root
      finder = Finder.new(@options)
      finder.find(@name)
    end
  end
end