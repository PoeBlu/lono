class Lono::Sets
  class Deploy < Lono::Cfn::Base
    def run
      if stack_set_exists?(@stack)
        Update.new(@options).run
      else
        Create.new(@options).run
      end
    end
  end
end
