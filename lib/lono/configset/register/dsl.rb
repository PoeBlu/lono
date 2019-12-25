module Lono::Configset::Register
  module Dsl
    def configset(name, options={})
      # puts "Dsl configset self #{self}".color(:purple)
      # caller_line = caller.grep(/evaluate_file/).first
      # puts "caller_line #{caller_line}"
      o = options.merge(name: name, from_registry_class: self.class)
      self.class.configsets << o
      store_for_validation(name)
    end

    # DSL
    def source(v)
      self.class.source = v
    end
  end
end
