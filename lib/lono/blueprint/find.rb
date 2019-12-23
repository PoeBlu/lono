require "yaml"

class Lono::Blueprint
  class Find < Lono::FindBase
    def initialize
      @type = "blueprints"
    end
  end
end