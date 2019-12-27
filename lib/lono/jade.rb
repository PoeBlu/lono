module Lono
  # Hodgepodge of .meta/config.yml and extra decorated methods like root and dependencies.
  class Jade
    extend Memoist
    class_attribute :tracked
    self.tracked = []
    class_attribute :downloaded
    self.downloaded = []

    attr_accessor :dependencies, :from, :depends_ons
    attr_reader :name, :type, :state
    def initialize(name, type, state={})
      # type: one of blueprint, configset, blueprint/configset
      # state holds either original registry from configset definition or parent jade which can be used to get the original configset defintion
      @name, @type, @state = name, type, state
      @materialized = false
      @resolved = false
      @depends_ons = []
      self.class.tracked << self
    end

    def resource_from_parent
      parent = state[:parent]
      resource = nil
      while parent
        resource = parent.state[:resource]
        parent = parent.state[:parent]
      end
      resource
    end

    def dependencies
      puts "dependencies!!!"
      @depends_ons.map do |o|
        self.class.new(o[:depends_on], "blueprint/configset", parent: o[:parent])
      end
    end

    # method_missing implmentation proved tricky to debug. Thinking its more productive to to be explicitly.
    %w[name template_type auto_camelize source_type].each do |meth|
      define_method(name) do
        if @config.nil?
          raise "Called '#{name}' method but need to materialize the jade first!"
        end
        @config[name.to_sym]
      end
    end

    # root is kind of special. root is needed for materialization but can accidentally get called too early
    # before materialization. So treat it specially with an error.
    def root
      raise "ERROR: root is not available until jade has been materialized" unless @config
      @config[:root]
    end

    def materialize
      @config = finder.find(@name)
      @config = download unless @config
      return false unless @config
      if @config[:source_type] == "materialized-local"
        self.class.downloaded << self
      end
      evaluate_meta_rb
      true
    end
    memoize :materialize

    # Must return config to set @config in materialize
    # Only allow download of Lono::Blueprint::Configset::Jade
    # Other configsets should be configured in project Gemfile.
    def download
      return @config unless @type == "blueprint/configset"
      jade = Lono::Configset::Materializer::Jade.new(self)
      jade.build
      # Pretty tricky. Need to flush memoized finder since the jade.build changes files
      # If we dont memoist at all, build process is 2x slower
      finder(true).find(@name)
    end
    memoize :download

    def evaluate_meta_rb
      return unless %w[blueprint/configset configset].include?(@type)
      meta = Lono::Configset::Meta.new(self)
      meta.evaluate
    end

    def resolved!
      @resolved = true
    end

    def resolved?
      @resolved
    end

    def finder
      "Lono::Finder::#{@type.camelize}".constantize.new
    end
    memoize :finder
  end
end
