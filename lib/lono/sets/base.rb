class Lono::Sets
  class Base < Lono::Cfn::Base
    def run
      save
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
