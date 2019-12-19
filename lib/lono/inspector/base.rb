module Lono::Inspector
  class Base < Lono::AbstractBase
    include Lono::Utils::Url

    delegate :required_parameters, :optional_parameters, :parameters, :data,
             to: :output_template

    extend Memoist

    def run
      generate
      templates = @template_name ? [@template_name] : all_templates
      templates.each do |template_name|
        perform(template_name)
      end
    end

    def generate
      if url?(@blueprint)
        downloader = Lono::Cfn::Download.new(source: @blueprint)
        @blueprint = downloader.name # override @blueprint
        downloader.download_path = "#{Lono.config.output_path}/#{@blueprint}/templates/#{@blueprint}.yml"
        downloader.run
      else
        generate_templates
      end
    end

    def generate_templates
      Lono::Template::Generator.new(@options.merge(quiet: false)).run
    end

    def all_templates
      templates_path = "#{Lono.config.output_path}/#{@blueprint}/templates"
      Dir.glob("#{templates_path}/**").map do |path|
        path.sub("#{templates_path}/", '').sub('.yml','') # template_name
      end
    end

    def output_template
      Lono::OutputTemplate.new(@blueprint, @template)
    end
    memoize :output_template
  end
end
