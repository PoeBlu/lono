module Lono
  # Hodgepodge of .meta/config.yml and extra decorated methods like root and dependencies.
  class Jade
    extend Memoist
    class_attribute :tracked
    self.tracked = []

    attr_accessor :dependencies, :from, :depends_ons
    attr_reader :name, :type
    def initialize(name, type)
      # type: one of blueprint, configset, blueprint/configset
      @name, @type = name, type
      @materialized = false
      @resolved = false
      @depends_ons = []
      self.class.tracked << self
    end

    def dependencies
      @depends_ons.map do |o|
        self.class.new(o[:depends_on], "blueprint/configset")
      end
    end

    # def method_missing(name, *args, &block)
    #   if @config.nil?
    #     raise "Called '#{name}' method but need to materialize the jade first!"
    #   end
    #   @config.symbolize_keys!
    #   if @config.key?(name)
    #     @config[name]
    #   else
    #     super
    #   end
    # end

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
      @config = find
      @config = download unless @config
      return false unless @config
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
      jade.install
      find # returns config
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

    def find
      finder.find(@name)
    end

    def finder
      "Lono::Finder::#{@type.camelize}".constantize.new
    end
    memoize :finder
  end
end
