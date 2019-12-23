require "json"

module Lono::Configset
  class Loader
    extend Memoist

    def initialize(name, resource)
      @name, @resource = name, resource
    end

    def load
      configset_root = Find.find(@name)
      path = "#{configset_root}/lib/configset.json"
      raise "configset #{path} not found" unless File.exist?(path)

      JSON.load(IO.read(path))
    end
    memoize :load

    class << self
      def combined_metadata_map
        combiner = Combiner.new
        Register.configsets.each do |c|
          puts "c #{c}"
          loader = Loader.new(c[:name], c[:resource])
          combiner.add(c[:name], c[:resource], loader.load)
        end
        combiner.combine
      end
    end
  end
end
