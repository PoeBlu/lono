module Lono
  class Cfn < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean

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

    desc "create STACK", "Create a CloudFormation stack using the generated template.", hide: true
    base_options.call
    wait_option.call
    long_desc Lono::Help.text("cfn/create")
    def create(stack)
      Create.new(options.merge(stack: stack)).run
    end

    desc "update STACK", "Update a CloudFormation stack using the generated template.", hide: true
    long_desc Lono::Help.text("cfn/update")
    base_options.call
    update_options.call
    wait_option.call
    def update(stack)
      Update.new(options.merge(stack: stack)).run
    end

    desc "deploy STACK", "Create or update a CloudFormation stack using the generated template."
    long_desc Lono::Help.text("cfn/deploy")
    base_options.call
    update_options.call
    wait_option.call
    def deploy(stack)
      Deploy.new(options.merge(stack: stack)).run
    end

    desc "delete STACK", "Delete a CloudFormation stack."
    long_desc Lono::Help.text("cfn/delete")
    option :sure, type: :boolean, desc: "Skips are you sure prompt"
    base_options.call
    wait_option.call
    def delete(stack)
      Delete.new(options.merge(stack: stack)).run
    end

    desc "cancel STACK", "Cancel a CloudFormation stack."
    long_desc Lono::Help.text("cfn/cancel")
    option :sure, type: :boolean, desc: "Skips are you sure prompt"
    wait_option.call
    def cancel(stack)
      Cancel.new(options.merge(stack: stack)).run
    end

    desc "preview STACK", "Preview a CloudFormation stack update.  This is similar to terraform's plan or puppet's dry-run mode."
    long_desc Lono::Help.text("cfn/preview")
    option :keep, type: :boolean, desc: "keep the changeset instead of deleting it afterwards"
    option :param_preview, type: :boolean, default: true, desc: "Show parameter diff preview."
    option :codediff_preview, type: :boolean, default: true, desc: "Show codediff changes preview."
    option :changeset_preview, type: :boolean, default: true, desc: "Show ChangeSet changes preview."
    base_options.call
    def preview(stack)
      Preview::Param.new(options.merge(stack: stack)).run if options[:param_preview]
      Preview::Codediff.new(options.merge(stack: stack)).run if options[:codediff_preview]
      Preview::Changeset.new(options.merge(stack: stack)).run if options[:changeset_preview]
    end

    desc "download STACK", "Download CloudFormation template from existing stack."
    long_desc Lono::Help.text("cfn/download")
    option :name, desc: "Name you want to save the template as. Default: existing stack name."
    base_options.call
    def download(stack)
      Download.new(options.merge(stack: stack)).run
    end

    desc "current", "Current stack that you're working with."
    long_desc Lono::Help.text("cfn/current")
    option :rm, type: :boolean, desc: "Remove all current settings. Removes `.lono/current`"
    option :name, desc: "Current stack name."
    def current
      Current.new(options).run
    end

    desc "status", "Shows current status of stack."
    long_desc Lono::Help.text("cfn/status")
    def status(stack)
      status = Lono::Cfn::Status.new(options.merge(stack: stack))
      success = status.run
      exit 3 unless success
    end
  end
end