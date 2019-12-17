class Lono::Sets::Status
  class Instance
    include Lono::AwsServices

    def initialize(stack_instance)
      @stack_instance = stack_instance
      @shown = []
      @output = "" # for say method and specs
    end

    def wait(to="completed")
      case to
      when "completed"
        wait_until_completed
      when "deleted"
        wait_until_deleted
      end
    end

    def wait_until_completed
      # resp.stack_instance.status : one of CURRENT, OUTDATED, INOPERABLE
      status = nil
      until completed?(status)
        resp = cfn.describe_stack_instance(
          stack_instance_account: @stack_instance.account,
          stack_instance_region: @stack_instance.region,
          stack_set_name: @stack_instance.stack_set_id,
        )
        stack_instance = resp.stack_instance
        show_instance(stack_instance)
        @shown << stack_instance
        status = resp.stack_instance.status
        unless completed?(status)
          sleep 2.5
        end
      end
    end

    def wait_until_deleted
      # resp.stack_instance.status : one of CURRENT, OUTDATED, INOPERABLE
      while true
        begin
          resp = cfn.describe_stack_instance(
            stack_instance_account: @stack_instance.account,
            stack_instance_region: @stack_instance.region,
            stack_set_name: @stack_instance.stack_set_id,
          )
        rescue Aws::CloudFormation::Errors::StackInstanceNotFoundException
          say status_line(@stack_instance.account, @stack_instance.region, "DELETED")
          break
        end
        stack_instance = resp.stack_instance
        show_instance(stack_instance)
        @shown << stack_instance

        sleep 2.5
      end
    end

    def show
      show_instance(@stack_instance)
    end

    def show_instance(stack_instance)
      already_shown = @shown.detect do |o|
        o[:account] == stack_instance[:account] &&
        o[:region] == stack_instance[:region] &&
        o[:status] == stack_instance[:status]
      end
      return if already_shown

      say status_line(stack_instance.account, stack_instance.region, stack_instance.status)
    end

    def status_line(account, region, status)
      [
        "Stack Instance:",
        "account".color(:purple), account,
        "region".color(:purple), region,
        "status".color(:purple), status,
      ].join(" ")
    end

    def say(text)
      ENV["LONO_TEST"] ? @output << "#{text}\n" : puts(text)
    end

    # status: one of CURRENT, OUTDATED, INOPERABLE
    def completed?(status)
      completed_statuses = %w[CURRENT INOPERABLE]
      completed_statuses.include?(status)
    end
  end
end
