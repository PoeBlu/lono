require 'json'

class Lono::Cfn
  class Download < Base
    def run
      puts "Download existing template to: #{download_path}"
      return if @options[:noop]
      download_template
    end

    def download_template
      resp = cfn.get_template(
        stack_name: @stack,
        template_stage: "Original"
      )
      body = convert_to_yaml(resp.template_body)
      IO.write(download_path, body)
    end

    def convert_to_yaml(body)
      json?(body) ? YAML.dump(JSON.parse(body)) : body
    end

    def json?(body)
      !!JSON.parse(body) rescue false
    end

    def download_path
      name = @options[:name] || @stack
      "/tmp/#{name}.yml"
    end
  end
end
