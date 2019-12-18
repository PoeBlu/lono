class Lono::Sets::Instances
  class Delete < Base
    include Lono::AwsServices
    include Lono::Utils::Sure
    include Validate

    def initialize(options={})
      @options = options
      @stack = options[:stack]
    end

    def run
      validate!

      sure?("Are you sure you want to delete the #{@stack} instances?", desc)

      # delete_stack_instances resp has operation_id
      # Could also use that to poll for status with the list_stack_set_operation_results
      # api. Currently, Instance::Status class not using this info. If we need will add the logic.
      resp = cfn.delete_stack_instances(
        options = {
          stack_set_name: @stack,
          accounts: accounts,
          regions: regions,
          retain_stacks: false,
        }
      )
      operation_id = resp.operation_id

      # Status tailing handled by caller
      o = @options.merge(
        filter: requested,
        start_on_outdated: false,
        operation_id: operation_id,
      )
      instances_status = Status.new(o)
      instances_status.run(to: "deleted") unless @options[:noop] # returns success: true or false
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