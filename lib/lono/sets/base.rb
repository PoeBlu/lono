class Lono::Sets
  class Base < Lono::Cfn::Base
    def run
      operation_id = nil
      # begin
        operation_id = save
      # rescue Exception => e
      #   puts "#{e.class}: #{e.message}"
      # end

      return unless @options[:wait]
      return unless operation_id # only available on update

      status = Status.new(@stack, operation_id)
      success = status.wait unless @options[:noop]
      exit 1 unless success
      success
    end

    def exit_unless_updatable!
      return true if ENV['LONO_ENV']
      return false if @options[:noop]

      status = Status.new(@stack, nil) # using status for completed?
      completed = status.completed?(status.stack_set_status)
      unless completed
        puts "Cannot update stack set because #{@stack} is not in an updatable state.  Stack set status: #{status.stack_set_status}".color(:red)
        quit(1)
      end
    end

    def build_options
      parameters = generate_all
      options = {
        stack_set_name: @stack,
        parameters: parameters,
        capabilities: capabilities, # ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
      }
      options[:tags] = tags unless tags.empty?
      set_template_url!(options)
      options
    end
  end
end
