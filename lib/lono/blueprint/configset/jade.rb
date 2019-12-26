module Lono::Blueprint::Configset
  class Jade < Lono::Configset::Jade
    def finder_class
      Lono::Finder::Blueprint::Configset
    end
  end
end
