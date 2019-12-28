class Lono::Configset
  class Preparer < Lono::AbstractBase
    def initialize(options={})
      super
      @blueprint = Register::Blueprint.new(options)
      @project   = Register::Project.new(options)
      @meta      = Meta.new(options)
      @resolver  = Resolver.new
    end

    def run
      register
      resolve_dependencies
      register_dependencies
      materialize_final
      validate_all! # run after final materializer
    end

    # Stores configsets registry items
    def register
      @project.register   # IE: looks up configs/BLUEPRINT/configsets/base.rb
      @blueprint.register # IE: looks up BLUEPRINT/config/configsets.rb
    end

    def resolve_dependencies
      puts "Resolving dependencies..."
      jades = Lono::Jade.tracked  # at this point only top-level
      @resolver.resolve(jades)
    end

    def register_dependencies
      @resolver.register
    end

    def materialize_final
      jades = Lono::Jade.downloaded
      Materializer::Final.new.build(jades)
    end

    def validate_all!
      @blueprint.validate!
      @project.validate!
    end
  end
end
