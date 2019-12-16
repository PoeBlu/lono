class Lono::Sets
  class Delete
    include Lono::AwsServices
    include Lono::Cfn::Sure

    def initialize(options={})
      @options = options
      @stack = options.delete(:stack)
    end

    def run
      message = "Deleting #{@stack} stack set."
      if @options[:noop]
        puts "NOOP #{message}"
      else
        are_you_sure?(@stack, :delete, stack_set: true)

        if stack_set_exists?(@stack)
          cfn.delete_stack_set(stack_set_name: @stack)
          puts message
        else
          puts "#{@stack.inspect} stack set does not exist".color(:red)
          return
        end
      end

    rescue Aws::CloudFormation::Errors::StackSetNotEmptyException => e
      puts "ERROR: #{e.class}: #{e.message}".color(:red)
      puts "The stack set must be empty before deleting. Cannot delete stack set until all stack instances are first deleted."
    end
  end
end
