class Lono::Configset::Meta
  module Dsl
    def depends_on(configset, options={})
      o = options.merge(
        from_method: __method__,
        depends_on: configset,
        parent: @jade,
      )
      @jade.depends_ons << o
    end
  end
end

