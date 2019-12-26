class Lono::Configset
  class Jade < Lono::Jade
    def finder_class
      Lono::Finder::Configset
    end

    def materialize
      # super
      @config = find_config
      @config = download unless @config


      evaluate_meta_rb
      true
    end

    def evaluate_meta_rb
      meta = Lono::Configset::Meta.new(self)
      meta.evaluate
    end
  end
end
