require "json"

class Lono::Configset
  class Loader
    extend Memoist
    include Dsl
    include EvaluateFile

    def initialize(registry={}, options={})
      @registry, @options = registry, options
      @name, @resource = registry[:name], registry[:resource]
      @blueprint = options[:blueprint]
    end

    def metdata_configset
      load
    end

    def load
      path = find_path
      copy_instance_variables
      content = RenderMePretty.result(path, context: self)
      if File.extname(path) == ".yml"
        YAML.load(content)
      else
        JSON.load(content)
      end
    end
    memoize :load

    def find_path
      paths = %w[configset.yml configset.json].map { |p| "#{configset_root}/lib/#{p}" }
      paths.find { |p| File.exist?(p) }
    end

    def configset_root
      config = finder_class.find(@name)
      unless config
        puts "finder_class #{finder_class}"
        raise "Unable to find configset #{@name}."
      end
      config[:root]
    end

    # Allow overriding in subclasses
    def finder_class
      Lono::Finder::Configset
    end

    def copy_instance_variables
      load_predefined_instance_variables
      copy_registry_instance_variables
    end

    def load_predefined_instance_variables
      path = "#{configset_root}/lib/variables.rb"
      return unless File.exist?(path)
      evaluate_file(path)
    end

    # Copy options from the original configset call as instance variables so its available. So:
    #
    #   configset("ssm", resource: "Instance", some_var: "test")
    #
    # Stores in the Configset::Registry
    #
    #   register = {name: "ssm", resource: "Instance", some_var: "test"}
    #
    # That has is passed into Loader.new(register, options)
    #
    # So these @registry varibles are copied over to instance variables.
    #
    def copy_registry_instance_variables
      @registry.each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end
  end
end
