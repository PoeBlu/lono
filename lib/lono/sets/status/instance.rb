class Lono::Sets::Status
  class Instance
    include Lono::AwsServices

    def initialize(stack_instance)
      @stack_instance = stack_instance
      @shown = []
      @output = "" # for say method and specs
    end

    def wait
      # resp.stack_instance.status : one of CURRENT, OUTDATED, INOPERABLE
      status = nil
      until completed?(status)
        resp = cfn.describe_stack_instance(
          stack_instance_account: @stack_instance.account,
          stack_instance_region: @stack_instance.region,
          stack_set_name: @stack_instance.stack_set_id,
        )
        stack_instance = resp.stack_instance
        show(stack_instance)
        @shown << stack_instance
        status = resp.stack_instance.status
        sleep 5 unless completed?(status)
      end
    end

    def show(stack_instance)
      already_shown = @shown.detect do |o|
        o[:status] == stack_instance[:status]
      end
      return if already_shown

      say [
        "Stack Instance info:",
        "account".color(:purple), stack_instance.account,
        "region".color(:purple), stack_instance.region,
        "status".color(:purple), stack_instance.status,
      ].join(" ")
    end

    def say(text)
      ENV["LONO_TEST"] ? @output << "#{text}\n" : puts(text)
    end

    def completed?(status)
      completed_statuses = %w[CURRENT INOPERABLE]
      completed_statuses.include?(status)
    end
  end
end
