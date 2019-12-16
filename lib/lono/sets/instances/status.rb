class Lono::Sets::Instances
  class Status
    include Lono::AwsServices

    def initialize(options={})
      @options = options
      @stack = options[:stack]
    end

    def run
      instances = Lono::Sets::Status::Instances.new(@options)
      instances.wait
    end
  end
end
