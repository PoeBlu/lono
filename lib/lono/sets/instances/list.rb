class Lono::Sets::Instances
  class List
    include Lono::AwsServices

    def initialize(options={})
      @options = options
      @stack = options.delete(:stack)
    end

    def run
      puts "Lono::Sets::Instances::List#run @stack #{@stack}"
      resp = cfn.list_stack_instances(stack_set_name: @stack)
      pp resp
    end
  end
end
