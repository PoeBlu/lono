class Lono::Sets::Status
  class Instance
    def initialize(stack_instance)
      @stack_instance = stack_instance
    end

    def tail(to="completed")
      case to
      when "completed"
        Completed.new(@stack_instance).tail
      when "deleted"
        Deleted.new(@stack_instance).tail
      end
    end
  end
end
