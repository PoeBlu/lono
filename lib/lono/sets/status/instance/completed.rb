# Refer to Lono::Sets::Status::Instance::Base for more detailed docs.
class Lono::Sets::Status::Instance
  class Completed < Base
    def tail
      display_one
      Thread.new do
        loop!
      end
    end

    def loop!
      # resp.stack_instance.status : one of CURRENT, OUTDATED, INOPERABLE
      status = nil
      until completed?(status)
        resp = display_one
        status = resp.stack_instance.status
        unless completed?(status)
          sleep 2.5
        end
      end
    end

    def display_one
      resp = cfn.describe_stack_instance(
        stack_instance_account: @stack_instance.account,
        stack_instance_region: @stack_instance.region,
        stack_set_name: @stack_instance.stack_set_id,
      )
      stack_instance = resp.stack_instance
      show_instance(stack_instance)
      @shown << stack_instance
      resp
    end

    # status: one of CURRENT, OUTDATED, INOPERABLE
    def completed?(status)
      completed_statuses = %w[CURRENT INOPERABLE]
      completed_statuses.include?(status)
    end
  end
end
