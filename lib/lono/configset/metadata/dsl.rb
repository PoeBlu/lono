class Lono::Configset::Metadata
  module Dsl
    def depends_on(configset, options={})
      o = options.merge(
        from_method: __method__,
        depends_on: configset,
        name: @parent_configset,
        finder_class: @finder_class,
      )
      self.class.registries << o
    end
  end
end
