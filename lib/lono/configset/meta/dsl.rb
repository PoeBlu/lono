class Lono::Configset::Meta
  module Dsl
    def depends_on(configset, options={})
      o = options.merge(
        depends_on: configset,
        parent: @jade,
      )
      @jade.depends_ons << o
    end
  end
end

