module Lono::Configset::Materializer
  class Final
    def build
      jades = Jade.built
      GemfileBuilder.new(jades).build
    end
  end
end
