module Lono
  class Sets < Command
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
    wait_option = Proc.new do
      option :wait, type: :boolean, desc: "Wait for stack operation to complete.", default: true
    end
    update_options = Proc.new do
      option :change_set, type: :boolean, default: true, desc: "Uses generated change set to update the stack.  If false, will perform normal update-stack."
      option :codediff_preview, type: :boolean, default: true, desc: "Show codediff changes preview."
      option :changeset_preview, type: :boolean, default: true, desc: "Show ChangeSet changes preview."
      option :param_preview, type: :boolean, default: true, desc: "Show parameter diff preview."
      option :sure, type: :boolean, desc: "Skips are you sure prompt"
    end

    desc "deploy STACK_SET_NAME", "Deploy CloudFormation stack set."
    long_desc Help.text("sets/deploy")
    base_options.call
    wait_option.call
    update_options.call
    def deploy(stack)
      Deploy.new(options.merge(stack: stack)).run
    end

    desc "status STACK_SET_NAME", "Show current status of stack set."
    long_desc Help.text("sets/status")
    def status(stack)
      status = Status.new(stack, nil, @options)
      success = status.run
      exit 3 unless success
    end

    desc "instances SUBCOMMAND", "instances subcommands"
    long_desc Help.text("sets/instances")
    subcommand "instances", Instances
  end
end
