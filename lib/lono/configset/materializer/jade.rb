require "bundler"

module Lono::Configset::Materializer
  class Jade
    class_attribute :built
    self.built = []

    extend Memoist

    def initialize(jade)
      @jade = jade
    end

    def build
      GemfileBuilder.new(@jade).build
      self.class.built << @jade
    end
  end
end
