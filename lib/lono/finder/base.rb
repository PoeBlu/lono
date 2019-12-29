require "bundler"
require "text-table"

module Lono::Finder
  class Base
    extend Memoist

    def initialize(options={})
      @options = options
      @blueprint = options[:blueprint]
      @lono_root = options[:lono_root] || Lono.root
    end

    # Returns root path of component: blueprint or configset
    def find(name, local_only: false)
      all = find_all(local_only: local_only)
      all.find { |spec| spec.name == name }
    end

    def find_all(local_only: false)
      local = project + vendor + gems
      if local_only
        local
      else
        local + materialized
      end
    end

    def project
      roots = path_roots("#{@lono_root}/app/#{type.pluralize}")
      components(roots, "project")
    end

    def vendor
      roots = path_roots("#{@lono_root}/vendor/#{type.pluralize}")
      components(roots, "vendor")
    end

    def gems
      components(gem_roots, "gem")
    end

    # Folders that each materialized gems to tmp/configsets
    def materialized
      components(materialized_gem_roots, "materialized")
    end

    # Components: blueprints or configsets
    # Returns array of config Hashes. Example structure:
    #
    #     [{
    #       name: "cfn-hup",
    #       root: "/path/to/gem/root",
    #       source_type: "project",
    #     },...]
    #
    def components(roots, source_type)
      components = []
      roots.each do |root|
        next unless detect?(root)
        jadespec = Lono::Jadespec.new(root, source_type)
        components << jadespec
      end
      components
    end
    memoize :components

    def detect?(root)
      expr = "#{root}/#{detection_path}"
      Dir.glob(expr).size > 0
    end

    def list(options={})
      table = Text::Table.new
      table.head = ["Name", "Path", "Type"]

      components = find_all
      components.each do |jadespec|
        pretty_path = jadespec.root.sub("#{Lono.root}/", "")
        unless options[:filter_materialized] && jadespec.source_type == "materialized"
          table.rows << [jadespec.name, pretty_path, jadespec.source_type]
        end
      end

      if table.rows.empty?
        puts "No #{type.pluralize} found."
      else
        puts(options[:message] || "Available #{type.pluralize}:")
        puts table
      end
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
      Bundler.load.specs.map do |spec|
        spec.full_gem_path
      end
    end
    memoize :gem_roots

    def materialized_gem_roots
      gemfile_lock = "#{Lono.root}/tmp/configsets/Gemfile.lock"
      return [] unless File.exist?(gemfile_lock)
      parser = Bundler::LockfileParser.new(Bundler.read_file(gemfile_lock))
      specs = parser.specs
      # __materialize__ only exists in Gem::LazySpecification and not in Gem::Specification
      specs.each { |spec| spec.__materialize__ }
      specs.map do |spec|
        spec.full_gem_path
      end
    end
    memoize :materialized_gem_roots

  public
    class << self
      def one_or_all(component)
        components = new.find_all.map { |spec| spec.name }
        component ? [component] : components
      end

      def find(name)
        new.find(name)
      end

      def list(options={})
        new.list(options)
      end
    end
  end
end
