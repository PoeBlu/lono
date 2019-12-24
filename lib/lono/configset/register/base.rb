require "active_support/core_ext/class"

class Lono::Configset::Register
  class Base < Lono::AbstractBase
    class_attribute :configsets
    class_attribute :validations

    def evaluate_file(path)
      return unless File.exist?(path)
      instance_eval(IO.read(path), path)
    end

    def self.clear!
      self.configsets = []
      self.validations = []
    end

    # Validate the configset at register time. So user finds out about error earlier.
    def save_for_validation(name)
      # save caller line to use later for pointing to exactly line
      caller_line = caller.grep(/evaluate_file/).first
      self.class.validations << {name: name, caller_line: caller_line}
    end

    # DSL
    def configset(name, options={})
      o = options.merge(name: name)
      self.class.configsets << o
      save_for_validation(name)
    end
  end
end
