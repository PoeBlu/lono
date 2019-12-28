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

    # method_missing implmentation proved tricky to debug. Thinking its more productive to to be explicitly.
    %w[template_type auto_camelize source_type].each do |meth|
      define_method(meth.to_sym) do
        if @config.nil?
          raise "Called '#{meth}' method but need to materialize the jade first!"
        end
        @config[meth.to_sym]
      end
    end

    # root is kind of special. root is needed for materialization but can accidentally get called too early
    # before materialization. So treat it specially with an error.
    def root
      raise "ERROR: root is not available until jade has been materialized" unless @config
      @config[:root]
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
      @depends_ons.map do |o|
        parent = o[:parent]
        self.class.new(o[:depends_on], parent.type, parent: parent)
      end
    end

    def materialize
      @config = finder.find(@name)
      download unless @config
      # Pretty tricky. Flush memoized finder(true) since download changes filesystem. Not memoizing at all is 2x slower
      @config = finder(true).find(@name)
      return nil unless @config
      if @config[:source_type] == "materialized"
        # possible "duplicated" jade instances with same name but will uniq in final materialized Gemfile
        self.class.downloaded << self
      end
      evaluate_meta_rb
      @config
    end
    memoize :materialize

    # Must return config to set @config in materialize
    # Only allow download of Lono::Blueprint::Configset::Jade
    # Other configsets should be configured in project Gemfile.
    def download
      return if finder.find(@name, local_only: true) # no need to download because locally found
      # 4 cases:
      # 1a) blueprint/configset top-level - download
      # 1b) blueprint/configset depends_on - download
      # 2a) configset top-level - dont download, will report to user with validate_all!
      # 2b) configset depends_on - download
      return unless %w[blueprint/configset configset].include?(@type) # TODO: support materializing nested blueprints later
      # only download jades that came from depends_on
      return unless @state[:parent] || @type == "blueprint/configset"
      jade = Lono::Configset::Materializer::Jade.new(self)
      jade.build
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
