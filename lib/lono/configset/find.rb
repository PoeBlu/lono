require "yaml"

module Lono::Configset
  class Find
    class << self
      extend Memoist

      def find(configset)
        # Check project configsets first
        info = all_project_configsets.find { |i| i["configset_name"] == configset }
        return info["path"] if info

        # Check gem specs
        result = specs.find do |spec|
          dot_meta = dot_meta_path(spec)
          config = YAML.load_file(dot_meta)
          config["configset_name"] == configset
        end
        result.full_gem_path if result
      end

      def all_project_configsets
        infos = []
        Dir.glob("#{Lono.root}/configsets/*").select do |p|
          dot_meta = dot_meta_path(p)
          next unless File.exist?(dot_meta)
          config = YAML.load_file(dot_meta)
          config["path"] = p
          infos << config
        end
        infos
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
end
