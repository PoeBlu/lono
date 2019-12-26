class Lono::Finder::Blueprint
  class Configset < Lono::Finder::Configset
    def initialize(options={})
      super
      @blueprint_root = options[:blueprint_root] || Lono.blueprint_root
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
      components(gem_roots, "materialized-local")
    end

    # Override Base
    def gemspecs
      lockfile = "#{Lono.root}/tmp/configsets/Gemfile.lock"
      return [] unless File.exist?(lockfile)
      parser = Bundler::LockfileParser.new(Bundler.read_file(lockfile))
      specs = parser.specs
      # __materialize__ only exists in Gem::LazySpecification and not in Gem::Specification
      specs.each { |spec| spec.__materialize__ }
      specs
    end
    memoize :gemspecs
  end
end
