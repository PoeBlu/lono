class Lono::Cfn
  class Delete
    include Lono::AwsServices
    include Util

    def initialize(options={})
      @options = options
      @stack = options.delete(:stack)
    end

    def run
      message = "Deleting #{@stack} stack."
      if @options[:noop]
        puts "NOOP #{message}"
      else
        are_you_sure?(@stack, :delete)

        if stack_exists?(@stack)
          cfn.delete_stack(stack_name: @stack)
          puts message
        else
          puts "#{@stack.inspect} stack does not exist".color(:red)
          return
        end
      end

      return unless @options[:wait]
      start_time = Time.now
      status.wait unless @options[:noop]
      took = Time.now - start_time
      puts "Time took for stack deletion: #{status.pretty_time(took).color(:green)}."
    end

    def status
      @status ||= Status.new(@stack)
    end
  end
end