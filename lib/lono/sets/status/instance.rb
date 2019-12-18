class Lono::Sets::Status
  class Instance
    def initialize(stack_instance, show_time_progress=false)
      @stack_instance, @show_time_progress = stack_instance, show_time_progress
    end

    def tail(to="completed")
      case to
      when "completed"
        Completed.new(@stack_instance, @show_time_progress).tail
      when "deleted"
        Deleted.new(@stack_instance, @show_time_progress).tail
      end
    end

    def show
      Show.new(@stack_instance, @show_time_progress).run
    end
  end
end
