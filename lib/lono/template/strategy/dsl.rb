module Lono::Template::Strategy
  class Dsl < Base
    attr_reader :results
    def initialize(options={})
      super
    end

    def run
      puts "Generating CloudFormation templates for blueprint #{@blueprint.color(:green)}:" unless @options[:quiet]
      paths = Dir.glob("#{Lono.config.templates_path}/**/*.rb")
      paths.select{ |e| File.file?(e) }.each do |path|
        build_template(path)
      end
    end

    def build_template(path)
      builder = Builder.new(path, @options)
      builder.build
    end
  end
end
