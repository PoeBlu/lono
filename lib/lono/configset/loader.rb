require "json"

class Lono::Configset
  class Loader
    extend Memoist

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
      unless path
        puts "WARN: Unable to find configset.yml or configset.json in #{configset_root}".color(:yellow)
        return
        # raise "Unable to find configset.yml or configset.json in #{configset_root}"
      end

      copy_registry_instance_variables
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
      # puts "find_path paths".color(:yellow)
      # pp paths
      paths.find { |path| File.exist?(path) }
    end

    def configset_root
      Find.find(@name)
    end
    memoize :configset_root

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
