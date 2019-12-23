require "yaml"

class Lono::Blueprint
  class Find < Lono::FindBase
    def initialize
      @type = "blueprints"
      @detection_path = "app/templates"
    end
  end
end