module Lono::Utils
  module Url
    def url?(source)
      !!(source =~ /^http/)
    end
  end
end