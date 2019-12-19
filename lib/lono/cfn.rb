module Lono
  class Cfn < Command
    options = Lono::Cfn::Options.new(self)

    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean

    desc "create STACK", "Create a CloudFormation stack using the generated template.", hide: true
    options.base
    options.wait
    long_desc Lono::Help.text("cfn/create")
    def create(stack)
      Create.new(options.merge(stack: stack)).run
    end

    desc "update STACK", "Update a CloudFormation stack using the generated template.", hide: true
    long_desc Lono::Help.text("cfn/update")
    options.base
    options.update
    options.wait
    def update(stack)
      Update.new(options.merge(stack: stack)).run
    end

    desc "deploy STACK", "Create or update a CloudFormation stack using the generated template."
    long_desc Lono::Help.text("cfn/deploy")
    options.base
    options.update
    options.wait
    def deploy(stack)
      Deploy.new(options.merge(stack: stack)).run
    end

    desc "delete STACK", "Delete CloudFormation stack."
    long_desc Lono::Help.text("cfn/delete")
    options.wait
    def delete(stack)
      Delete.new(options.merge(stack: stack)).run
    end

    desc "cancel STACK", "Cancel a CloudFormation stack."
    long_desc Lono::Help.text("cfn/cancel")
    options.wait
    def cancel(stack)
      Cancel.new(options.merge(stack: stack)).run
    end

    desc "preview STACK", "Preview a CloudFormation stack update.  This is similar to terraform's plan or puppet's dry-run mode."
    long_desc Lono::Help.text("cfn/preview")
    option :keep, type: :boolean, desc: "keep the changeset instead of deleting it afterwards"
    option :param_preview, type: :boolean, default: true, desc: "Show parameter diff preview."
    option :codediff_preview, type: :boolean, default: true, desc: "Show codediff changes preview."
    option :changeset_preview, type: :boolean, default: true, desc: "Show ChangeSet changes preview."
    options.base
    def preview(stack)
      Preview::Param.new(options.merge(stack: stack)).run if options[:param_preview]
      Preview::Codediff.new(options.merge(stack: stack)).run if options[:codediff_preview]
      Preview::Changeset.new(options.merge(stack: stack)).run if options[:changeset_preview]
    end

    desc "download STACK", "Download CloudFormation template from existing stack."
    long_desc Lono::Help.text("cfn/download")
    option :name, desc: "Name you want to save the template as. Default: existing stack name."
    options.base
    option :url, desc: "url with template, normally downloading from existing stack but url overrides that"
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