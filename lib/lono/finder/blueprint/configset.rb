class Lono::Finder::Blueprint
  class Configset < Lono::Finder::Configset
    attr_accessor :gemfile_lock
    def initialize(options={})
      super
      @blueprint_root = options[:blueprint_root] || Lono.blueprint_root
    end

    def local
      blueprint + vendor + gems
    end

    def all
      blueprint + vendor + gems + materialized
    end

    def blueprint
      roots = path_roots("#{@blueprint_root}/app/#{type.pluralize}")
      components(roots, "blueprint")
    end
  end
end
