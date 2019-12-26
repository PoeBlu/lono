class Lono::Configset
  class Jade < Lono::Jade
    def finder_class
      Lono::Finder::Configset
    end

    def materialize
      super
      evaluate_meta_rb
      true
    end

    def evaluate_meta_rb
      meta = Lono::Configset::Meta.new(self)
      meta.evaluate
    end

    def download
      puts "TODO: store error if download is unsuccessful"
      exit 1
    end
  end
end
