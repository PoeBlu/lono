module Lono
  # Hodgepodge of .meta/config.yml and extra decorated methods like root and dependencies.
  class Jade
    extend Memoist
    class_attribute :tracked
    self.tracked = {}

    class << self
      def get(name)
        jade = self.tracked[name]
        return jade if jade

        jade = new(name)
        self.tracked[name] = jade
        jade
      end
    end

    attr_accessor :dependencies, :from, :depends_ons
    def initialize(name)
      @name = name
      @materialized = false
      @resolved = false
      @depends_ons = []
    end

    def dependencies
      @depends_ons.map do |o|
        self.class.get(o[:depends_on])
      end
    end

    def method_missing(name, *args, &block)
      @config.symbolize_keys!
      if @config.key?(name)
        @config[name]
      else
        super
      end
    end

    # root is kind of special. root is needed for materialization but can accidentally get called too early
    # before materialization. So treat it specially with an error.
    def root
      raise "ERROR: root is not available until jade has been materialized" unless @config
      @config[:root]
    end

    def materialize
      @config = find_config
      @config = download unless @config
      return false unless @config
      true
    end
    memoize :materialize

    def download
      # noop - only for blueprint configset materialized-remote
    end

    def resolved!
      @resolved = true
    end

    def resolved?
      @resolved
    end

  private
    def find_config
      finder_class.find_config(@name)
    end
  end
end
