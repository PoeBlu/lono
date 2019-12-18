# Refer to Lono::Sets::Status::Instance::Base for more detailed docs.
class Lono::Sets::Status::Instance
  class Deleted < Base
    def tail
      display_one
      Thread.new do
        loop!
      end
    end

    def loop!
      # resp.stack_instance.status : one of CURRENT, OUTDATED, INOPERABLE
      while true
        begin
          display_one
        rescue Aws::CloudFormation::Errors::StackInstanceNotFoundException
          say status_line(@stack_instance.account, @stack_instance.region, "DELETED")
          break
        end
        sleep 2.5
      end
    end

    def display_one
      resp = cfn.describe_stack_instance(
                  stack_instance_account: @stack_instance.account,
                  stack_instance_region: @stack_instance.region,
                  stack_set_name: @stack_instance.stack_set_id)
      stack_instance = resp.stack_instance
      show_instance(stack_instance)
      @shown << stack_instance
      resp
    end
  end
end
