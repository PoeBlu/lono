class Lono::Cfn
  module Sure
    def are_you_sure?(stack_name, action, stack_set: false)
      if @options[:sure]
        sure = 'y'
      else
        stack_text = stack_set ? "stack set" : "stack"
        message = case action
        when :update
          "Are you sure you want to update the #{stack_name.color(:green)} #{stack_text} with the changes? (y/N)"
        when :delete
          "Are you sure you want to delete the #{stack_name.color(:green)} #{stack_text}? (y/N)"
        end
        puts message
        sure = $stdin.gets
      end

      unless sure =~ /^y/
        puts "Whew! Exiting without running #{action}."
        exit 0
      end
    end
  end
end
