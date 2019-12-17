class Lono::Sets::Status
  class Instances
    include Lono::AwsServices

    def initialize(options={})
      @options = options
      @stack = options[:stack]
    end

    def wait
      puts "Stack Instance statuses..."
      wait_until_outdated if @options[:start_on_outdated]

      with_instances do |instance|
        Thread.new { instance.wait }
      end.map(&:join)
    end

    def show
      with_instances do |instance|
        Thread.new { instance.show }
      end.map(&:join)
    end

    def with_instances
      stack_instances.map do |stack_instance|
        instance = Instance.new(stack_instance)
        yield(instance)
      end
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
    def instances
      stack_instances.map { |stack_instance| Instance.new(stack_instance) }
    end

    def stack_instances
      resp = cfn.list_stack_instances(stack_set_name: @stack)
      summaries = resp.summaries
      # filter is really only used internally. So it's fine to keep it as complex data structure since that's what we
      # build it up as in Lono::Sets::Instances::Deploy
      filter = @options[:filter] # [["112233445566", "us-west-1"],["112233445566", "us-west-2"]]
      return summaries unless filter

      summaries.reject do |s|
        intersect = [[s.account, s.region]] & filter
        intersect.empty?
      end
    end
  end
end
