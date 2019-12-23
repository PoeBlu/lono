require "json"

class Lono::Configset
  class Loader
    extend Memoist

    def initialize(options={})
      @options = options
      @name, @resource = options[:name], options[:resource]
    end

    def load
      path = find_path
      unless path
        raise "Unable to find lib/configset.yml or configset.json in #{configset_root}"
      end

      copy_instance_variables
      content = RenderMePretty.result(path, context: self)
      if File.extname(path) == ".yml"
        YAML.load(content)
      else
        JSON.load(content)
      end
    end
    memoize :load

    def copy_instance_variables
      @options.each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end

    def find_path
      paths = %w[configset.yml configset.json].map { |p| "#{configset_root}/lib/#{p}" }
      paths.find { |path| File.exist?(path) }
    end

    def configset_root
      Find.find(@name)
    end
    memoize :configset_root

    class << self
      def combined_metadata_map
        combiner = Combiner.new
        Register.configsets.each do |c|
          loader = Loader.new(c)
          combiner.add(c, loader.load)
        end
        combiner.combine
        Register.clear! # in case of lono generate for all templates
      end
    end
  end
end
