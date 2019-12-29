require "rubygems"

module Lono
  class Jadespec
    extend Memoist

    delegate :metadata, :name, to: :gemspec

    attr_accessor :from
    attr_reader :root, :source_type
    def initialize(root, source_type)
      @root, @source_type = root, source_type
    end

    def exist?
      !!gemspec_file
    end

    def gemspec
      Gem::Specification::load(gemspec_file)
    end
    memoize :gemspec

    def gemspec_file
      Dir.glob("#{@root}/*.gemspec").first
    end

    def template_type
      metadata[:template_type] || "dsl"
    end

    def auto_camelize
      metadata[:auto_camelize] || false
    end
  end
end
