class Lono::Sets::Status
  class Instances
    include Lono::AwsServices

    def initialize(options)
      @options = options
      @stack = options[:stack]
    end

    def wait
      waiters = stack_instances.map do |stack_instance|
        instance = Instance.new(stack_instance)
        Thread.new do
          instance.wait
        end
      end
      waiters.map(&:join)
    end

    # TODO: scope this to accounts and regions from cli or configs
    def stack_instances
      resp = cfn.list_stack_instances(stack_set_name: @stack)
      resp.summaries
    end
  end
end
