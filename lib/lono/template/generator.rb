require "yaml"

class Lono::Template
  class Generator < Lono::AbstractBase
    def run
      # Examples:
      #   Erb.new(b, options.dup).run
      #   Dsl.new(b, options.dup).run
      generator_class = "Lono::Template::#{template_type.classify}"
      generator_class = Object.const_get(generator_class)
      generator_class.new(@options).run
    end

    def template_type
      meta_config = "#{Lono.blueprint_root}/.meta/config.yml"
      data = YAML.load_file(meta_config)
      data["template_type"] || "dsl"
    end
  end
end
