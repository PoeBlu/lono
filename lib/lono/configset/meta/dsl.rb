class Lono::Configset::Meta
  module Dsl
    def depends_on(configset, options={})
      o = options.merge(
        depends_on: configset,
        parent: @jade,
      )
      @jade.depends_ons << o unless @jade.depends_ons.include?(o)
    end
  end
end

