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
      register_dependency_configsets
      materialize_final
      validate_all! # run after final materializer
    end

    def register_dependency_configsets
      puts "register_dependency_configsets"
      Register::Blueprint.configsets
      Resolver.dependencies.each do |jade|
        puts "jade name #{jade.name} type #{jade.type} parent #{jade.state[:parent].name.inspect}"

        registry = {
          resource: jade.resource_from_parent,
          name: jade.name,
        }

        if jade.type == "blueprint/configset"
          Register::Blueprint.prepend(registry)
        elsif jade.type == "configset"
          Register::Project.prepend(registry)
        end
      end
    end

    # Create configsets registry items
    def register
      @project.register
      @blueprint.register
    end

    def create_top_level_jades
      Register::Blueprint.configsets.each do |registry|
        Lono::Jade.new(registry[:name], "blueprint/configset", registry).materialize
      end
      Register::Project.configsets.each do |registry|
        Lono::Jade.new(registry[:name], "configset", registry).materialize
      end
    end

    # Creates lower-level dependency jades
    def resolve_dependencies
      jades = Lono::Jade.tracked  # at this point only top-level
      Resolver.new.resolve(jades)
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
