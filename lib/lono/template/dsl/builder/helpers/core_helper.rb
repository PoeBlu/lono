module Lono::Template::Dsl::Builder::Helpers
  module CoreHelper
    extend Memoist

    def stack_name
      @options[:stack]
    end

    def setting
      Lono::Setting.new
    end
    memoize :setting
  end
end