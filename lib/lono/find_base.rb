require "text-table"

# Subclass must implement initialize and set @type and @detection_path. Example:
#
#     class Lono::Blueprint
#       class Find < Lono::FindBase
#         def initialize
#           @type = "blueprints"
#           @detection_path = "app/templates"
#         end
#       end
#     end
#
module Lono
  class FindBase
    extend Memoist

    class << self
      def one_or_all(component)
        component ? [component] : all.map { |c| c["name"] }
      end

      def find(component)
        new.find(component)
      end

      def list_all
        new.list_all
      end

      def all
        new.all
      end
    end

    # Returns root path of component: configset or blueprint
    def find(component)
      found = all.find { |i| i["name"] == component }
      return found["path"] if found
    end

    # Returns: [Component,...]
    #
    # Component structure:
    #
    #     {
    #       "name" => "vpc", # blueprint or configset name
    #       "path" => "/path/to/component/root",
    #       "source" => "local", # local or gem
    #     }
    #
    def all
      components = []

      # local components
      Dir.glob("#{Lono.root}/app/#{@type}/*").select do |root|
        next unless correct_component?(root)
        config = yaml_load_file(dot_meta_path(root))
        next unless config
        config["path"] = root
        config["source_type"] = "local"
        components << config
      end

      # gem components
      specs.each do |spec|
        root = component_root(spec)
        next unless correct_component?(root)
        config = yaml_load_file(dot_meta_path(root))
        next unless config
        config["path"] = root
        config["source_type"] = "gem"
        components << config
      end

      components.sort_by { |c| c ["name"] }
    end

    def correct_component?(root)
      expr = "#{root}/#{@detection_path}"
      Dir.glob(expr).size > 0
    end

    def yaml_load_file(path)
      return unless File.exist?(path)

      config = YAML.load_file(path)
      if config.key?("blueprint_name")
        deprecation_warning("blueprint name in #{path} is DEPRECATED. Please rename blueprint_name to name.")
        config["name"] = config["blueprint_name"]
      end
      config
    end

    # Only the component specs
    def specs
      Bundler.load.specs
    end
    memoize :specs

    def dot_meta_path(root)
      "#{root}/.meta/config.yml"
    end

    # root of the compoment: configset or blueprint
    def component_root(source)
      if source.is_a?(String) # path to folder
        source
      else # spec
        source.full_gem_path
      end
    end

    def list_all
      puts "Available #{@type}:"
      table = Text::Table.new
      table.head = ["Name", "Path", "Type"]

      components = all
      components.each do |c|
        pretty_path = c["path"].sub("#{Lono.root}/", "")
        table.rows << [c["name"], pretty_path, c["source_type"]]
      end

      puts table
    end

    @@deprecation_warnings = []
    def deprecation_warning(message)
      return if ENV["LONO_MUTE_DEPRECATION"]
      message = "#{message} export LONO_MUTE_DEPRECATION=1 to mute"
      puts message unless @@deprecation_warnings.include?(message)
      @@deprecation_warnings << message
    end
  end
end
