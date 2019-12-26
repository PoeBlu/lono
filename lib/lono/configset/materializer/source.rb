module Lono::Configset::Materializer
  class Source
    def initialize(lono_settings=nil)
      @lono_settings = lono_settings || Lono::Setting.new.data
    end

    def settings
      @lono_settings.dig("configsets", "source") || {}
    end

    # c - configset registry item
    def options(jade)
      if location.include?("git@") || location.include?("https")
        {git: "#{location}/#{jade.name}"}
      else
        {path: "#{location}/#{jade.name}"}
      end
    end

    def location
      ENV["LONO_CONFIGSET_SOURCE"] ||
      Lono::Configset::Register::Blueprint.source ||
      settings["location"] ||
      "git@github.com:boltopspro"
    end

    def central
      !!settings["central"]
    end
  end
end
