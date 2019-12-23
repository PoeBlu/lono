# Subclass must implement initialize and set @type and @name_key. Example:
#
#     module Lono::Configset
#       class Find < Lono::FindBase
#         def initialize
#           @type = "configsets"
#           @name_key = "configset_name"
#         end
#       end
#     end
#
module Lono
  class FindBase
    extend Memoist

    class << self
      def one_or_all(component)
        component ? [component] : all_components
      end

      def find(component)
        new.find(component)
      end

      def list_all
        all = new.all
        all.sort.each do |c|
          full_path = find(c)
          path = full_path.sub("#{Lono.root}/", "")
          puts "  #{c}: #{path}"
        end
      end
    end

    # Returns both project and gem blueprints
    def all
      project = all_components.map { |c| c["name"] }

      gems = specs.map do |spec|
        dot_meta = dot_meta_path(spec)
        next unless File.exist?(dot_meta)
        config = YAML.load_file(dot_meta)
        config["name"]
      end.compact

      both = project + gems
      both.uniq
    end

    # Returns root path of component: configset or blueprint
    def find(component)
      # Check project @type first
      info = all_components.find { |i| i["name"] == component }
      return info["path"] if info

      # Check gem specs
      spec = specs.find do |s|
        dot_meta = dot_meta_path(s)
        next unless File.exist?(dot_meta)
        config = yaml_load_file(dot_meta)
        config["name"] == component
      end
      spec.full_gem_path if spec
    end

    def all_components
      components = []
      Dir.glob("#{Lono.root}/#{@type}/*").select do |p|
        dot_meta = dot_meta_path(p)
        next unless File.exist?(dot_meta)
        config = yaml_load_file(dot_meta)
        config["path"] = p
        components << config
      end
      components
    end

    def yaml_load_file(path)
      config = YAML.load_file(path)
      if config.key?("blueprint_name")
        puts "WARN: blueprint name in #{path} is DEPRECATED. Please rename blueprint_name to name." unless ENV["LONO_MUTE_DEPRECATION"]
        config["name"] = config["blueprint_name"]
      end
      config
    end

    # Only the blueprint specs
    def specs
      specs = Bundler.load.specs
      specs.select do |spec|
        File.exist?(dot_meta_path(spec))
      end
    end
    memoize :specs

    def dot_meta_path(source)
      if source.is_a?(String) # path to folder
        "#{source}/.meta/config.yml"
      else # spec
        "#{source.full_gem_path}/.meta/config.yml"
      end
    end
  end
end
