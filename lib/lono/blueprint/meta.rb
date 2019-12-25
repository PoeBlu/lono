require "yaml"

class Lono::Blueprint
  class Meta
    extend Memoist

    def initialize(blueprint)
      @blueprint = blueprint
    end

    def data
      Lono::Finder::Blueprint.find(@blueprint)
    end
    memoize :data

    def auto_camelize?(target_section)
      auto_camelize = data['auto_camelize']
      # auto_camelize.nil? for backward compatibility
      return true if auto_camelize.nil? || auto_camelize == true

      if auto_camelize == "except_resource"
        return target_section != "resource"
      end

      if auto_camelize.is_a?(Array)
        auto_camelize.include?(target_section)
      end
    end
  end
end
