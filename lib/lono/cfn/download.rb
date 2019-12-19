require 'json'
require 'open-uri'

class Lono::Cfn
  class Download
    include Lono::Utils::Url

    attr_writer :download_path
    def initialize(options={})
      @options = options
      @source = options[:source]
    end

    def run
      puts "Downloading template to: #{download_path}"
      return if @options[:noop]
      download_template
    end

    def download_template
      body = download_source
      body = convert_to_yaml(body)
      FileUtils.mkdir_p(File.dirname(download_path))
      IO.write(download_path, body)
    end

    def download_source
      if url?(@source)
        open(@source).read # url
      else
        resp = cfn.get_template(
          source_name: @source,
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
      @download_path || "/tmp/#{name}.yml"
    end

    def name
      return @options[:name]  if @options[:name]

      if url?(@source)
        url = @source
        File.basename(url, File.extname(url)).gsub(/[^a-z0-9]/i, "-")
      else
        @source
      end
    end
  end
end
