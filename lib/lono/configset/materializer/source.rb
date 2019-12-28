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
        options = git_options(jade.state) # merge original git related options from configset
        {git: "#{location}/#{jade.name}"}.merge(options)
      else
        {path: "#{location}/#{jade.name}"}
      end
    end

    def args(jade)
      jade.state[:args]
    end

    def git_options(registry)
      o = {}
      o[:branch] = registry[:branch]
      o[:ref] = registry[:ref]
      o[:tag] = registry[:tag]
      o.delete_if { |k, v| v.nil? }
      o
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
