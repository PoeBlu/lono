class Lono::Sets::Instances
  class Delete < Base
    include Lono::AwsServices
    include Lono::Cfn::Sure
    include Validate

    def initialize(options={})
      @options = options
      @stack = options[:stack]
    end

    def run
      validate!

      sure?("Are you sure you want to delete the #{@stack} instances?", desc)

      resp = cfn.delete_stack_instances(
        options = {
          stack_set_name: @stack,
          accounts: accounts,
          regions: regions,
          retain_stacks: false,
        }
      )
      puts "resp:"
      pp resp
      puts "Stack Instances deleting"
    end

    def desc
      <<~EOL
      These stack instances will be deleted:

          accounts: #{accounts.join(',')}
          regions: #{regions.join(',')}

      EOL
    end
  end
end