class Lono::Configset::Metadata
  module Dsl
    def depends_on(configset, options={})
      puts "depends_on @parent_configset: #{@parent_configset.inspect}".color(:purple)
      o = options.merge(from_method: __method__, name: @parent_configset, depends_on: configset)
      self.class.registry << o
    end
  end
end
