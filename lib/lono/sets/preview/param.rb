module Lono::Sets::Preview
  class Param < Lono::Sets::Base
    def run
      puts "Lono::Sets::Preview::Param#run"
      # TODO: param preview    cfn.describe_stack_set => stack_set.parameters
    end
  end
end