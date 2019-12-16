class Lono::Sets
  class Instances < Lono::Command
    # TODO: base_options: lots in common with cfn X 3
    base_options = Proc.new do
      # common to create, update and deploy
      option :config, aliases: "c", desc: "override convention and specify both the param and variable file to use"
      option :blueprint, desc: "override convention and specify the template file to use"
      option :capabilities, type: :array, desc: "iam capabilities. Ex: CAPABILITY_IAM, CAPABILITY_NAMED_IAM"
      option :iam, type: :boolean, desc: "Shortcut for common IAM capabilities: CAPABILITY_IAM, CAPABILITY_NAMED_IAM"
      option :lono, type: :boolean, desc: "invoke lono to generate CloudFormation templates", default: true
      option :param, aliases: "p", desc: "override convention and specify the param file to use"
      option :rollback, type: :boolean, desc: "rollback", default: true
      option :tags, type: :hash, desc: "Tags for the stack. IE: name:api-web owner:bob"
      option :template, desc: "override convention and specify the template file to use"
      option :variable, aliases: "v", desc: "override convention and specify the variable file to use"
    end
    update_options = Proc.new do
      option :change_set, type: :boolean, default: true, desc: "Uses generated change set to update the stack.  If false, will perform normal update-stack."
      option :codediff_preview, type: :boolean, default: true, desc: "Show codediff changes preview."
      option :changeset_preview, type: :boolean, default: true, desc: "Show ChangeSet changes preview."
      option :param_preview, type: :boolean, default: true, desc: "Show parameter diff preview."
      option :sure, type: :boolean, desc: "Skips are you sure prompt"
    end
    sets_options = Proc.new do
      option :regions, type: :array, desc: "List of regions to apply stack set to. IE: us-west-2 us-east-1"
      option :accounts, type: :array, desc: "List of accounts to apply stack set to. IE: 112233445566 223344556677"
    end

    desc "list STACK_SET_NAME", "Deploy CloudFormation stack set."
    long_desc Lono::Help.text("sets/instances/list")
    base_options.call
    update_options.call
    sets_options.call
    def list(stack)
      List.new(options.merge(stack: stack)).run
    end

    desc "deploy STACK_SET_NAME", "Deploy CloudFormation stack set."
    long_desc Lono::Help.text("sets/instances/deploy")
    base_options.call
    update_options.call
    sets_options.call
    def deploy(stack)
      Deploy.new(options.merge(stack: stack)).run
    end

    desc "status STACK_SET_NAME", "Show current status of stack instances."
    long_desc Lono::Help.text("sets/instances/status")
    sets_options.call
    def status(stack)
      status = Status.new(options.merge(stack: stack))
      success = status.run
      exit 3 unless success
    end
  end
end