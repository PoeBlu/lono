require "bundler"
require "text-table"

module Lono::Finder
  class Base
    extend Memoist

    class << self
      def one_or_all(component)
        components = new.all.map { |c| c[:name] }
        component ? [component] : components
      end

      def find(name)
        new.find(name)
      end

      def list(message=nil)
        new.list(message)
      end

      # # Automatically set the jade type correctly
      # def new_jade(name)
      #   # jade_class one of: Lono::Finder::Blueprint, Lono::Finder::Configset, Lono::Finder::Blueprint::Configset
      #   jade_class = self.to_s.gsub('Finder::','')
      #   # jade_type one of: blueprint, configset, blueprint/configset
      #   jade_type = jade_class.underscore
      #   jade = Lono::Jade.new(name, jade_type)
      #   jade.materialize
      #   jade
      # end
    end

    def initialize(options={})
      @options = options
      @blueprint = options[:blueprint]
      @lono_root = options[:lono_root] || Lono.root
    end

    # Returns root path of component: blueprint or configset
    def find(name)
      all.find { |c| c[:name] == name }
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
    # Returns array of config Hashes. Example structure:
    #
    #     [{
    #       name: "cfn-hup",
    #       root: "/path/to/gem/root",
    #       source_type: "project-local",
    #     },...]
    #
  def components(roots, source_type)
      components = []
      roots.each do |root|
        next unless detect?(root)
        meta_path = dot_meta_path(root)
        next unless File.exist?(meta_path)
        config = load_yaml_file(meta_path)
        config.symbolize_keys!
        config[:root] = root
        config[:source_type] = source_type
        components << config
      end
      components
    end
    memoize :components

    def load_yaml_file(dot_meta_path)
      return {} unless File.exist?(dot_meta_path)
      config = YAML.load_file(dot_meta_path)
      if config.key?("blueprint_name")
        deprecation_warning("blueprint name in #{dot_meta_path} is DEPRECATED. Please rename blueprint_name to name.")
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

    def dot_meta_path(root)
      "#{root}/.meta/config.yml"
    end

    def detect?(root)
      expr = "#{root}/#{detection_path}"
      Dir.glob(expr).size > 0
    end

    def list(message=nil)
      puts(message || "Available #{type.pluralize}:")
      table = Text::Table.new
      table.head = ["Name", "Path", "Type"]

      components = all
      components.each do |jade|
        pretty_path = jade.root.sub("#{Lono.root}/", "")
        table.rows << [jade.name, pretty_path, jade.source_type]
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
        spec.full_gem_path
      end
    end

    def gemspecs
      Bundler.load.specs
    end
    memoize :gemspecs
  end
end
