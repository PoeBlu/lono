class Lono::Sets::Status
  class Instances
    include Lono::AwsServices

    def initialize(options)
      @options = options
      @stack = options[:stack]
    end

    def wait
      wait_until_outdated if @options[:start_on_outdated]
      waiters = stack_instances.map do |stack_instance|
        instance = Instance.new(stack_instance)
        Thread.new do
          instance.wait
        end
      end
      waiters.map(&:join)
    end

    # If we dont wait until OUTDATED, during a `lono sets deploy` it'll immediately think that the instance statuses are done
    def wait_until_outdated
      outdated = false
      until outdated
        outdated = stack_instances.detect { |stack_instance| stack_instance.status == "OUTDATED" }
        sleep 2.5
      end
    end

    # TODO: scope this to accounts and regions from cli or configs
    def stack_instances
      resp = cfn.list_stack_instances(stack_set_name: @stack)
      resp.summaries
    end
  end
end
