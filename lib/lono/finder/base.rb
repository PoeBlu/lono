require "bundler"
require "text-table"

module Lono::Finder
  class Base
    extend Memoist

    class << self
      def one_or_all(component)
        components = new.all.map { |jade| jade.name }
        component ? [component] : components
      end

      def find(name)
        new.find(name)
      end

      def list(message=nil)
        new.list(message)
      end
    end

    def initialize(options={})
      @options = options
      @blueprint = options[:blueprint]
      @lono_root = options[:lono_root] || Lono.root
    end

    # Returns root path of component: blueprint or configset
    def find(name)
      jade = all.find { |j| j.name == name }
      jade if jade
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
        meta_path = dot_meta_path(root)
        next unless File.exist?(meta_path)
        jade = Lono::Jade.new(meta_path, root: root, source_type: source_type)
        components << jade
      end
      components
    end
    memoize :components

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
