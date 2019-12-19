require 'json'
require 'open-uri'

class Lono::Cfn
  class Download
    include Lono::AwsServices
    include Lono::Utils::Url

    def initialize(options={})
      @options = options
      @stack, @url = options[:stack], options[:url]
    end

    def run
      puts "Downloading template to: #{download_path}"
      return if @options[:noop]
      download_template
    end

    def download_template
      body = download_stack
      body = convert_to_yaml(body)
      FileUtils.mkdir_p(File.dirname(download_path))
      IO.write(download_path, body)
    end

    def download_stack
      if @url
        open(@url).read # url
      else
        resp = cfn.get_template(
          stack_name: @stack,
          template_stage: "Original"
        )
        resp.template_body
      end
    end

    def convert_to_yaml(body)
      json?(body) ? YAML.dump(JSON.parse(body)) : body
    end

    def json?(body)
      !!JSON.parse(body) rescue false
    end

    def download_path
      @url ? "#{Lono.config.output_path}/#{@blueprint}/templates/#{@blueprint}.yml" : "/tmp/#{name}.yml"
    end

    def name
      @options[:name] || @stack
    end
  end
end
