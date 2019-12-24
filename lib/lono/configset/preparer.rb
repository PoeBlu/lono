class Lono::Configset
  class Preparer < Lono::AbstractBase
    def initialize(options={})
      super
      @blueprint = Lono::Configset::Register::Blueprint.new(options)
      @project   = Lono::Configset::Register::Project.new(options)
    end

    def run
      register
      materialize
      validate!
    end

    def register
      @blueprint.register
      @project.register
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
