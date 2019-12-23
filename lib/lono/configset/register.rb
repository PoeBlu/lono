require "active_support/core_ext/class"

class Lono::Configset
  class Register < Lono::AbstractBase
    class_attribute :configsets, :blueprint_configsets
    self.configsets = []
    self.blueprint_configsets = []

    def run
      load_blueprint_configsets
      load_configsets
    end

    def load_blueprint_configsets
      blueprint_configsets = find_blueprint_configsets
      evaluate_file(blueprint_configsets) if blueprint_configsets
    end

    def find_blueprint_configsets
      path = "#{Lono.blueprint_root}/config/configsets.rb"
      path if File.exist?(path)
    end

    def load_configsets
      options = ActiveSupport::HashWithIndifferentAccess.new(@options.dup)
      options[:blueprint] = @blueprint
      options[:stack] ||= @blueprint

      location = Lono::ConfigLocation.new("configsets", options, Lono.env)
      evaluate_file(location.lookup_base) if location.lookup_base
      evaluate_file(location.lookup) if location.lookup # config file
    end

    def evaluate_file(path)
      return unless File.exist?(path)
      instance_eval(IO.read(path), path)
    end

    def self.clear!
      self.configsets = []
    end

    # DSL
    def configset(name, options={})
      # Store the fact that is a blueprint_configset - these are loaded separately
      internal = caller.detect { |p| p =~ %r{config/configsets\.rb} } # blueprint_configsets are considered internal
      validate_configset!(name, internal)
      o = options.merge(name: name)
      if internal
        self.class.blueprint_configsets << o
      else
        self.class.configsets << o
      end
      self.class.configsets << options.merge(name: name, internal: internal)
    end

    # Validate the configset at register time. So user finds out about error earlier.
    def validate_configset!(name, internal)
      configset_root = Find.find(name, internal)
      unless configset_root
        # TODO: print exact line where configset is invalid
        puts "ERROR: Configset with name #{name} not found. Double check your configs/#{@blueprint}/configsets files." # .color(:red)
        puts "WARN: Configset #{name} not found".color(:yellow)
        # raise "Configset #{name} not found"
      end
    end
  end
end
