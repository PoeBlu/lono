require "bundler"

module Lono::Configset::Blueprint
  class Finder
    extend Memoist

    def initialize(options={})
      @options = options
      @blueprint = options[:blueprint]
    end

    def find(name)
      found = all.find { |i| i["name"] == name }
      return found["path"] if found
    end

    def all
      configsets = []

      # local components
      Dir.glob("#{Lono.blueprint_root}/app/configsets/*").each do |root|
        config = yaml_load_file(dot_meta_path(root))
        next unless config
        config["path"] = root
        config["source_type"] = "local"
        configsets << config
      end

      # gem configsets
      gemspecs.each do |spec|
        spec.__materialize__
        root = spec.full_gem_path
        config = yaml_load_file(dot_meta_path(root))
        next unless config
        config["path"] = root
        config["source_type"] = "gem"
        configsets << config
      end
      configsets
    end

    def find_local(name)
      local_configset_paths.find do |root|
        config = yaml_load_file(dot_meta_path(root))
        next unless config
        config["name"] == name
      end
    end

    def local_configset_paths
      Dir.glob("#{Lono.blueprint_root}/app/configsets/*").to_a
    end
    memoize :local_configset_paths

    def gemspecs
      lockfile = "#{Lono.root}/tmp/configsets/Gemfile.lock"
      return [] unless File.exist?(lockfile)
      parser = Bundler::LockfileParser.new(Bundler.read_file(lockfile))
      parser.specs
    end
    memoize :gemspecs

    def dot_meta_path(root)
      "#{root}/.meta/config.yml"
    end

    def yaml_load_file(path)
      return unless File.exist?(path)
      YAML.load_file(path)
    end
  end
end
