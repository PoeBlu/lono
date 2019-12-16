class Lono::Cfn
  class Deploy < Base
    def save_stack(parameters)
      if stack_exists?(@stack)
        Update.new(@options).update_stack(parameters)
      else
        Create.new(@options).create_stack(parameters)
      end
    end
  end
end
