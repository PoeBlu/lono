class Lono::Configset
  # Hodgepodge of .meta/config.yml and extra decorated methods like root and dependencies.
  class Jade
    extend Memoist

    attr_accessor :dependencies, :from
    def initialize(config_path, attrs={})
      @config_path, @attrs = config_path, attrs
      @dependencies = []
    end

    def exist?
      !data.empty?
    end

    def data
      hash = load_yaml_file
      hash.merge(@attrs)
    end
    memoize :data

    def method_missing(name, *args, &block)
      data.symbolize_keys!
      if data.key?(name)
        data[name]
      else
        super
      end
    end

  private
    def load_yaml_file
      return {} unless File.exist?(@config_path)
      config = YAML.load_file(@config_path)
      if config.key?("blueprint_name")
        deprecation_warning("blueprint name in #{@config_path} is DEPRECATED. Please rename blueprint_name to name.")
        config["name"] = config["blueprint_name"]
      end
      config
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
