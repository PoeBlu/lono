module Lono::Configset::Materializer
  class Source
    def initialize(lono_settings=nil)
      @lono_settings = lono_settings || Lono::Setting.new.data
    end

    # String provide to gem method in Gemfile.  Example:
    #
    #      gem "mygem", "v0.1.0", git: "xxx"
    #
    def gem_args(jade)
      args = jade.state.args
      args = args.map { |s| %Q|"#{s}"| }.join(', ')

      options = options(jade)
      options = options.inject([]) { |r,(k,v)| r << %Q|#{k}: "#{v}"| }.join(', ')

      "#{args}, #{options}"
    end

    def options(jade)
      registry = jade.state
      if registry.options.key?(:path)
        options = {}
        options[:path] = registry.options[:path]
        return(options)
      end

      if registry.options.key?(:git)
        options = git_options(registry)
        options[:git] = registry.options[:git]
        return(options)
      end

      if location.include?("git@") || location.include?("https")
        options = git_options(registry) # merge original git related options from configset
        {git: "#{location}/#{jade.name}"}.merge(options)
      else
        {path: "#{location}/#{jade.name}"}
      end
    end

    def git_options(registry)
      o = {}
      o[:branch] = registry.options[:branch]
      o[:ref] = registry.options[:ref]
      o[:tag] = registry.options[:tag]
      o.delete_if { |k, v| v.nil? }
      o
    end

    def location
      ENV["LONO_MATERIALIZED_GEMS_SOURCE"] ||
      Lono::Configset::Register::Blueprint.source ||
      settings["source"] ||
      "git@github.com:boltopspro" # default_location
    end

    def settings
      @lono_settings.dig("materialized_gems") || {}
    end
  end
end
