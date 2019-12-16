class Lono::Sets::Instances
  class Deploy < Lono::Cfn::Base
    def run
      parameters = generate_all
      puts "parameters #{parameters}"

      resp = cfn.update_stack_instances(
        stack_set_name: @stack,
        accounts: @options[:accounts],
        regions: @options[:regions],
      )
      pp resp

      # TODO: gracefully handle missing parameters :accounts :regions
      # if stack_set_exists?(@stack)
      #   update(parameters)
      # else
      #   create(parameters)
      # end
    end
  end
end
