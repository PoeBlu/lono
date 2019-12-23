require "yaml"

class Lono::Configset
  class Find < Lono::FindBase
    def initialize
      @type = "configsets"
      @detection_path = "lib/configset.*"
    end
  end
end
