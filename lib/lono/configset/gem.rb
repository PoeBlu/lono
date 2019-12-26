class Lono::Configset
  # Hodgepodge of .meta/config.yml and extra decorated methods like root and dependencies
  class Gem
    extend Memoist

    attr_accessor :dependencies
    def initialize(config_path, attrs={})
      @config_path = config_path
      @dependencies = []
    end

    def exist?
      !!data
    end

    def data
      load_yaml_file
    end
    memoize :data

    def root
    end

    def method_missing(name, *args, &block)
      if data.key?(name.to_s)
        send(name)
      else
        super
      end
    end

  private
    def load_yaml_file
      return unless File.exist?(@config_path)
      config = YAML.load_file(@config_path)
      if config.key?("blueprint_name")
        deprecation_warning("blueprint name in #{path} is DEPRECATED. Please rename blueprint_name to name.")
        config["name"] = config["blueprint_name"]
      end
      config
    end

    def dot_meta_path(root)
      "#{root}/.meta/config.yml"
    end

    @@deprecation_warnings = []
    def deprecation_warning(message)
      # comment out for now
      # return if ENV["LONO_MUTE_DEPRECATION"]
      # message = "#{message} export LONO_MUTE_DEPRECATION=1 to mute"
      # puts message unless @@deprecation_warnings.include?(message)
      # @@deprecation_warnings << message
    end
  end
end
