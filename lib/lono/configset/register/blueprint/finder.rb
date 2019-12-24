require "bundler"

class Lono::Configset::Register::Blueprint
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

    def gemspecs
      lockfile = "#{Lono.root}/tmp/configsets/Gemfile.lock"
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
