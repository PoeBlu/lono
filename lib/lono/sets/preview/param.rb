module Lono::Sets::Preview
  # Inherits from Lono::Cfn::Preview::Param and override what's needed:
  #
  #      stack_parameters
  #
  class Param < Lono::Cfn::Preview::Param
    # TODO: param preview    cfn.describe_stack_set => stack_set.parameters
    def run
      puts "Lono::Sets::Preview::Param#run"
      return unless stack_set_exists?(@stack)

      generated_parameters # eager call generated_parameters so its output is above Parameter Diff Preview
      puts "Parameter Diff Preview:".color(:green)
      if @options[:noop]
        puts "NOOP CloudFormation parameters preview for #{@stack} update"
        return
      end

      write_to_tmp(existing_path, existing_params)
      write_to_tmp(new_path, new_params)

      show_diff(existing_path, new_path)
    end

    def stack_parameters
      stack_set_parameters
    end
    memoize :stack_parameters

    def stack_set_parameters
      resp = cfn.describe_stack_set(stack_set_name: @stack)
      resp.stack_set.parameters
    end
  end
end
