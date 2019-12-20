class Lono::CLI
  class Options
    def initialize(cli)
      @cli = cli
    end

    def url
      with_cli_scope do
        option :url, desc: "url or file with with template, overrides template generation"
      end
    end

    def template
      with_cli_scope do
        option :template, desc: "override convention and specify the template file to use"
      end
    end

  private
    def with_cli_scope(&block)
      @cli.instance_eval(&block)
    end
  end
end
