class Lono::Cfn
  class Options
    def initialize(cli)
      @cli = cli # Lono::Cfn and Lono::Sets only
    end

    def base
      with_cli_scope do
        # Lono::Cfn only
        if self == Lono::Cfn
          option :rollback, type: :boolean, desc: "rollback", default: true
        end

        # common to Lono::Cfn and Lono::Sets
        # Lono::Cfn create, update and deploy
        # Lono::Sets deploy
        option :blueprint, desc: "override convention and specify the template file to use"
        option :capabilities, type: :array, desc: "iam capabilities. Ex: CAPABILITY_IAM, CAPABILITY_NAMED_IAM"
        option :config, aliases: "c", desc: "override convention and specify both the param and variable file to use"
        option :iam, type: :boolean, desc: "Shortcut for common IAM capabilities: CAPABILITY_IAM, CAPABILITY_NAMED_IAM"
        option :param, aliases: "p", desc: "override convention and specify the param file to use"
        option :tags, type: :hash, desc: "Tags for the stack. IE: Name:api-web Owner:bob"
        option :template, desc: "override convention and specify the template file to use"
        option :variable, aliases: "v", desc: "override convention and specify the variable file to use"
      end
    end

    def wait
      with_cli_scope do
        option :wait, type: :boolean, desc: "Wait for stack operation to complete.", default: true
        option :sure, type: :boolean, desc: "Skip are you sure prompt" # moved to base but used by commands like `lono cfn delete` also. Just keep here.
      end
    end

    def update
      with_cli_scope do
        # Lono::Cfn only
        if self == Lono::Cfn
          option :change_set, type: :boolean, default: true, desc: "Uses generated change set to update the stack.  If false, will perform normal update-stack."
          option :changeset_preview, type: :boolean, default: true, desc: "Show ChangeSet changes preview."
        end
        # common to Lono::Cfn and Lono::Sets
        option :codediff_preview, type: :boolean, default: true, desc: "Show codediff changes preview."
        option :param_preview, type: :boolean, default: true, desc: "Show parameter diff preview."
      end
    end

  private
    def with_cli_scope(&block)
      @cli.instance_eval(&block)
    end
  end
end
