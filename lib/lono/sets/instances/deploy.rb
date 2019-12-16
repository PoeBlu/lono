class Lono::Sets::Instances
  class Deploy < Lono::Cfn::Base
    def run
      parameters = generate_all
      if stack_set_exists?(@stack)
        update(parameters)
      else
        create(parameters)
      end
    end
  end
end
