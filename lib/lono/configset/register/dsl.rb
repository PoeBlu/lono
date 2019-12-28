module Lono::Configset::Register
  module Dsl
    def configset(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      o = options.merge(args: args, name: args.first)
      self.class.configsets << o unless self.class.configsets.include?(o)
      store_for_validation(o)
    end

    # DSL
    def source(v)
      self.class.source = v
    end
  end
end
