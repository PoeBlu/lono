module Lono::Blueprint::Configset
  class Jade < Lono::Configset::Jade
    def finder_class
      Lono::Finder::Blueprint::Configset
    end

    # Must return config to set @config in materialize
    # Only allow download of Lono::Blueprint::Configset::Jade
    # Other configsets should be configured in project Gemfile.
    def download
      jade = Lono::Configset::Materializer::Jade.new(self)
      jade.install
      find_config # returns config
    end
  end
end
