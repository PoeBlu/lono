require "yaml"

module Lono::Configset
  class Find < Lono::FindBase
    def initialize
      @type = "configsets"
    end
  end
end
