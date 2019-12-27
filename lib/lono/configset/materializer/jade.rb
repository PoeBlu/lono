require "bundler"

module Lono::Configset::Materializer
  class Jade
    extend Memoist

    def initialize(jade)
      @jade = jade
    end

    def build
      GemfileBuilder.new(@jade).build
    end
  end
end
