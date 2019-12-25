class Lono::Configset::Metadata
  module Dsl
    def depends_on(configset, options={})
      puts "depends_on self #{self}"
      puts caller
      o = options.merge(from_method: __method__, configset: configset)
      self.class.registry << o
    end
  end
end
