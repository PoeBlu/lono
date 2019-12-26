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
      resolve_dependencies
      materialize
      validate!
    end

    def register
      @project.register
      @blueprint.register
      @metadata.register
    end

    def resolve_dependencies
      DependencyResolver.new(@options).resolve(@metadata.metas)
    end

    def materialize
      Lono::Blueprint::Configset::Downloader.new(@options).run
    end

    def validate!
      @blueprint.validate!
      @project.validate!
    end
  end
end
