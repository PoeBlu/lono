class Lono::Sets::Instances
  class Delete < Base
    include Lono::AwsServices
    include Lono::Cfn::Sure
    include Validate

    def initialize(options={})
      @options = options
      @stack = options[:stack]
    end

    def run
      validate!

      are_you_sure?(@stack, :delete, stack_set: true)

      resp = cfn.delete_stack_instances(
        options = {
          stack_set_name: @stack,
          accounts: accounts,
          regions: regions,
          retain_stacks: false,
        }
      )
      puts "Stack Instances deleting"
    end
  end
end