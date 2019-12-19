require "active_support/core_ext/class"

# The Completed and Deleted classes inherit from Base.
# They implement `tail` and should not override `show`.
#
# They guarantee at least one status line is shown.
# After which they start a thread that tails until a "terminal" status is detected. However, describe_stack_instance
# resp.stack_instance.status returns:
#
#   CURRENT, OUTDATED, INOPERABLE
#
# There is no well-defined terminal status. For example, sometimes the terminal status is `CURRENT`, when the stack
# instance updates successfully:
#
#   CURRENT -> OUTDATED -> CURRENT (terminal)
#
# But sometimes the terminal state is `OUTDATED`, when the stack instance fails to update:
#
#   CURRENT -> OUTDATED (terminal)
#
# Essentially, the `describe_stack_instance` resp does not provide enough information to determine the completion of
# the `tail` logic.
#
# Hence the Completed and Deleted classes cannot be used to control the end of the polling loop. Instead, the calling
# logic is responsible for and should control when to end the polling loop.
#
# Example in Lono::Sets::Status::Instances:
#
#   with_instances do |instance|
#     Thread.new { instance.tail(to) }
#   end.map(&:join)
#   wait_until_stack_set_operation_complete
#
# The Instances logic waits on the operation results instead because its more accurate. We know from
# `describe_stack_set_operation` when the status is actually complete. The describe_stack_set_operation
# stack_set_operation.status is one of RUNNING, SUCCEEDED, FAILED, STOPPING, STOPPED.
#
# In this case, there are threads within threads. The first thread at the Instances level starts polling status
# in parallel. The instance.tail delegates to the Completed and Deleted classes.
#
# Finally, the Completed and Deleted classes are designed to block with the first poll request. So it can show at
# least one status line. Then it starts it's own thread to poll for more statuses.  Those latter statuses are not
# guaranteed to be shown. This is the responsibility of the Instances class since it has the information required to
# determine when to finish the polling loop.
#
class Lono::Sets::Status::Instance
  class Base
    include Lono::AwsServices

    class_attribute :show_time_progress

    def initialize(stack_instance)
      @stack_instance = stack_instance
      @shown = []
      @output = "" # for say method and specs
    end

    def show_instance(stack_instance)
      already_shown = @shown.detect do |o|
        o[:account] == stack_instance[:account] &&
        o[:region] == stack_instance[:region] &&
        o[:status] == stack_instance[:status]
      end
      return if already_shown

      say status_line(stack_instance.account, stack_instance.region, stack_instance.status)
    end

    def show_time_progress
      self.class.show_time_progress
    end

    def status_line(account, region, status)
      time = Time.now.strftime("%F %r") if show_time_progress
      [
        time,
        "Stack Instance:",
        "account".color(:purple), account,
        "region".color(:purple), region,
        "status".color(:purple), status,
      ].compact.join(" ")
    end

    def say(text)
      ENV["LONO_TEST"] ? @output << "#{text}\n" : puts(text)
    end
  end
end
