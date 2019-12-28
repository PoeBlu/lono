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

    # Stores configsets registry items
    def register
      @project.register   # IE: looks up configs/BLUEPRINT/configsets/base.rb
      @blueprint.register # IE: looks up BLUEPRINT/config/configsets.rb
    end

    def create_top_level_jades
      Register::Blueprint.configsets.each do |registry|
        Lono::Jade.new(registry[:name], "blueprint/configset", registry)
      end
      Register::Project.configsets.each do |registry|
        Lono::Jade.new(registry[:name], "configset", registry)
      end

      debug_configsets
    end

    # Creates lower-level dependency jades
    def resolve_dependencies
      jades = Lono::Jade.tracked  # at this point only top-level
      puts "resolve_dependencies Lono::Jade.tracked names #{Lono::Jade.tracked.map(&:name)}"
      Resolver.new.resolve(jades)
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

      debug_configsets
    end

    def materialize_final
      jades = Lono::Jade.downloaded
      Materializer::Final.new.build(jades)
    end

    def validate_all!
      @blueprint.validate!
      @project.validate!
    end

    def debug_configsets
      puts "Register::Blueprint.configsets.size #{Register::Blueprint.configsets.size}"
      pp Register::Blueprint.configsets
      puts "Register::Project.configsets.size #{Register::Project.configsets.size}"
      pp Register::Project.configsets
    end
  end
end
