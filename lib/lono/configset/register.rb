require "active_support/core_ext/class"

module Lono::Configset
  class Register < Lono::AbstractBase
    class_attribute :configsets
    self.configsets = []

    def run
      load_configsets
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

    # DSL
    def configset(name, resource:)
      puts "Register configset name #{name} resource #{resource}".color(:yellow)
      self.class.configsets << {name: name, resource: resource}
    end
  end
end
