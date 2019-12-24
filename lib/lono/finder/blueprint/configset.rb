class Lono::Finder::Blueprint
  class Configset < Lono::Finder::Configset
    def initialize(options={})
      super
      @blueprint_root = options[:blueprint_root] || Lono.blueprint_root
    end

    # Special method for Downloader. Does not consider materialized configsets
    def find_local(name)
      found = local.find { |i| i["name"] == name }
      return found["path"] if found
    end

    def local
      blueprint + vendor
    end

    def all
      blueprint + vendor + materialized
    end

    def blueprint
      roots = path_roots("#{@blueprint_root}/app/#{type.pluralize}")
      components(roots, "blueprint-local")
    end

    # Folders that each materialized gems to tmp/configsets
    def materialized
      roots = path_roots("#{@lono_root}/tmp/#{type.pluralize}")
      components(roots, "materialized-local")
    end
  end
end
