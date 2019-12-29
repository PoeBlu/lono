require "yaml"

class Lono::Template
  class Generator < Lono::AbstractBase
    def run
      # Examples:
      #   Erb.new(b, options.dup).run
      #   Dsl.new(b, options.dup).run
      generator_class = "Lono::Template::Strategy::#{template_type.camelize}"
      generator_class = Object.const_get(generator_class)
      generator_class.new(@options).run
    end

    def template_type
      if @options[:source]
        "source"
      else
        jadespec = Lono::Jadespec.new(Lono.blueprint_root, "unknown") # only using to get template_type metadata for now
        jadespec.template_type
      end
    end
  end
end
