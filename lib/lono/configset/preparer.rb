class Lono::Configset
  class Preparer < Lono::AbstractBase
    def initialize(options={})
      super
      @blueprint = Register::Blueprint.new(options)
      @project   = Register::Project.new(options)
      @meta      = Meta.new(options)
    end

    def run
      register
      create_top_level_jades
      resolve_dependencies
      materialize_final
      # validate_all! # run after final materializer
      exit
    end

    # Create configsets registry items
    def register
      @project.register
      @blueprint.register
    end

    def create_top_level_jades
      Register::Blueprint.configsets.each do |registry|
        Lono::Jade.new(registry[:name], "blueprint").materialize
      end
      Register::Project.configsets.each do |registry|
        Lono::Jade.new(registry[:name], "configset").materialize
      end
    end

    # Creates lower-level dependency jades
    def resolve_dependencies
      jades = Lono::Jade.tracked
      Dependencies.new.resolve(jades)
    end

    def materialize_final
      Materializer::Final.new.build
    end

    def validate_all!
      @blueprint.validate!
      @project.validate!
    end
  end
end
