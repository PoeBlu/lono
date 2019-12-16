class Lono::Sets
  class Status
    extend Memoist
    include Lono::AwsServices
    include Lono::Utils::PrettyTime

    def initialize(stack, operation_id, options={})
      @stack, @operation_id, @options = stack, operation_id, options
      @shown = []
      @output = "" # for say method and specs
    end

    def run
      @operation_id = latest_operation_id unless @operation_id
      wait
    end

    def latest_operation_id
      resp = cfn.list_stack_set_operations(
        stack_set_name: @stack,
        max_results: 1,
      )
      resp.summaries.first.operation_id
    end

    def stack_set_status
      @operation_id = latest_operation_id unless @operation_id
      resp = cfn.describe_stack_set_operation(
        stack_set_name: @stack,
        operation_id: @operation_id,
      )
      resp.stack_set_operation.status
    end

    def wait
      status = nil
      until completed?(status)
        resp = cfn.describe_stack_set_operation(
          stack_set_name: @stack,
          operation_id: @operation_id,
        )
        stack_set_operation = resp.stack_set_operation
        show(stack_set_operation)
        @shown << stack_set_operation
        status = stack_set_operation.status
        if completed?(status)
          show_time_spent(stack_set_operation)
        else
          # Instances::Status.new(@options).run # TODO: also add to completed?
          sleep 5
        end
      end
    end

    def show_time_spent(stack_set_operation)
      seconds = stack_set_operation.end_timestamp - stack_set_operation.creation_timestamp
      time_took = pretty_time(seconds).color(:green)
      puts "Time took to complete stack set operation: #{time_took}"
    end

    def show(stack_set_operation)
      already_shown = @shown.detect do |o|
        o[:status] == stack_set_operation[:status]
      end
      return if already_shown

      say "Stack Set Operation Status: #{stack_set_operation.status}"
    end

    def say(text)
      ENV["LONO_TEST"] ? @output << "#{text}\n" : puts(text)
    end

    # one of RUNNING, SUCCEEDED, FAILED, STOPPING, STOPPED
    def completed?(status)
      completed_statuses = %w[SUCCEEDED FAILED STOPPED]
      completed_statuses.include?(status)
    end
  end
end
