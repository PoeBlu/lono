class Lono::Sets
  class Instances < Lono::Command
    options = Proc.new do
      option :accounts, type: :array, desc: "List of accounts to apply stack set to. IE: 112233445566 223344556677"
      option :regions, type: :array, desc: "List of regions to apply stack set to. IE: us-west-2 us-east-1"
      option :sure, type: :boolean, desc: "Skip are you sure prompt"
    end

    desc "delete STACK_SET", "Delete CloudFormation stack set instances."
    long_desc Lono::Help.text("sets/instances/delete")
    option :sure, type: :boolean, desc: "Skips are you sure prompt"
    options.call
    def delete(stack)
      Delete.new(options.merge(stack: stack)).run
    end

    desc "sync STACK_SET", "Sync CloudFormation stack set instances."
    long_desc Lono::Help.text("sets/instances/sync")
    options.call
    option :delete, type: :boolean, default: true, desc: "Delete stack instances that are not provided"
    option :blueprint, desc: "override convention and specify the template file to use"
    def sync(stack)
      Sync.new(options.merge(stack: stack)).run
    end

    desc "list STACK_SET", "List CloudFormation stack set instances."
    long_desc Lono::Help.text("sets/instances/list")
    def list(stack)
      List.new(options.merge(stack: stack)).run
    end

    desc "status STACK_SET", "Show current status of stack instances."
    long_desc Lono::Help.text("sets/instances/status")
    def status(stack)
      status = Status.new(options.merge(stack: stack))
      success = status.run
      exit 3 unless success
    end
  end
end
