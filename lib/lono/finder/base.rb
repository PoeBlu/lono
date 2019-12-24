require "bundler"
require "text-table"

module Lono::Finder
  class Base
    extend Memoist

    class << self
      def one_or_all(component)
        component ? [component] : all
      end

      def find(name)
        new.find(name)
      end

      def list
        new.list
      end
    end

    def initialize(options={})
      @options = options
      @blueprint = options[:blueprint]
      @lono_root = options[:lono_root] || Lono.root
    end

    # Returns root path of component: blueprint or configset
    def find(name)
      found = all.find { |i| i["name"] == name }
      return found["path"] if found
    end

    def all
      project + vendor + gems
    end

    def project
      roots = path_roots("#{@lono_root}/app/#{type.pluralize}")
      components(roots, "project-local")
    end

    def vendor
      roots = path_roots("#{@lono_root}/vendor/#{type.pluralize}")
      components(roots, "vendor-local")
    end

    def gems
      components(gem_roots, "gem-remote")
    end

    # Components: blueprints or configsets
    def components(roots, source_type)
      components = []
      roots.each do |root|
        next unless detect?(root)
        config = yaml_load_file(dot_meta_path(root))
        next unless config
        config["path"] = root
        config["source_type"] = source_type
        components << config
      end
      components
    end
    memoize :components

    def detect?(root)
      expr = "#{root}/#{detection_path}"
      Dir.glob(expr).size > 0
    end

    def list
      puts "Available #{type.pluralize}:"
      table = Text::Table.new
      table.head = ["Name", "Path", "Type"]

      components = all
      components.each do |c|
        pretty_path = c["path"].sub("#{Lono.root}/", "")
        table.rows << [c["name"], pretty_path, c["source_type"]]
      end

      puts table
    end

  private
    def path_roots(path)
      Dir.glob("#{path}/*").to_a
    end

    # Example return:
    #
    #     [
    #       "/home/ec2-user/.rbenv/versions/2.5.6/lib/ruby/gems/2.5.0/gems/rake-13.0.1",
    #       "/home/ec2-user/.rbenv/versions/2.5.6/lib/ruby/gems/2.5.0/gems/thor-0.20.3"
    #     ]
    #
    def gem_roots
      gemspecs.map do |spec|
        spec.__materialize__ if spec.respond_to?(:__materialize__) # only exists on Gem::LazySpecification and not on Gem::Specification
        spec.full_gem_path
      end
    end

    def gemspecs
      Bundler.load.specs
    end
    memoize :gemspecs

    def yaml_load_file(path)
      return unless File.exist?(path)
      config = YAML.load_file(path)
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
