module Lono::Configset::Register
  module Dsl
    def configset(name, options={})
      o = options.merge(name: name)
      self.class.configsets << o unless self.class.configsets.include?(o)
      store_for_validation(name)
    end

    # DSL
    def source(v)
      self.class.source = v
    end
  end
end
