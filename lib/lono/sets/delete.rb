class Lono::Sets
  class Delete
    include Lono::AwsServices
    include Lono::Utils::Sure

    def initialize(options={})
      @options = options
      @stack = options.delete(:stack)
    end

    def run
      message = "Deleting #{@stack} stack set."
      if @options[:noop]
        puts "NOOP #{message}"
      else
        sure?("Are you sure you want to delete the #{@stack} stack set?", "Be sure that it emptied of stack instances first.")

        if stack_set_exists?(@stack)
          cfn.delete_stack_set(stack_set_name: @stack) # resp is an Empty structure, so much get operation_id from status
          puts message
        else
          puts "#{@stack.inspect} stack set does not exist".color(:red)
          return
        end
      end

      return true unless @options[:wait]
      status = Status.new(@options)
      success = status.run unless @options[:noop]
      operation_id = status.operation_id # getting operation_id from status because cfn.delete_stack_set resp is an Empty structure
      unless success
        summaries_errors(operation_id)
        exit 1
      end
      success

    rescue Aws::CloudFormation::Errors::StackSetNotEmptyException => e
      puts "ERROR: #{e.class}: #{e.message}".color(:red)
      puts "The stack set must be empty before deleting. Cannot delete stack set until all stack instances are first deleted."
    end
  end
end
