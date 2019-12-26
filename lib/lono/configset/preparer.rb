class Lono::Configset
  class Preparer < Lono::AbstractBase
    def initialize(options={})
      super
      @blueprint = Register::Blueprint.new(options)
      @project   = Register::Project.new(options)
      @metadata   = Metadata.new(options)
    end

    def run
      register
      materialize_current_registered

      # resolve_dependencies
      validate!
    end

    def materialize_current_registered
      puts "materialize_current_registered"
      configset_registries.each do |registry|
        pp registry
      end
    end

    def register
      @project.register
      @blueprint.register
      # @metadata.register
    end

    def resolve_dependencies
      DependencyResolver.new(@options).resolve(@metadata.metas)
    end

    def download
      Lono::Blueprint::Configset::Downloader.new(@options).run
    end

    def validate!
      @blueprint.validate!
      @project.validate!
    end

  private
    def configset_registries
      Lono::Configset::Register::Blueprint.configsets +
      Lono::Configset::Register::Project.configsets
    end
  end
end
