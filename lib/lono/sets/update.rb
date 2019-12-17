class Lono::Sets
  class Update < Base
    def save
      message = "Updating #{@stack} stack set"
      if @options[:noop]
        puts "NOOP #{message}"
        return
      end

      # TODO: implement
      # deleted = delete_rollback_stack
      # if deleted
      #   create(parameters)
      #   return
      # end

      unless stack_set_exists?(@stack)
        puts "Cannot update a stack set because the #{@stack} does not exists."
        return
      end
      exit_unless_updatable!

      # TODO: param preview    cfn.describe_stack_set => stack_set.parameters
      # TODO: codediff preview cfn.describe_stack_set => stack_set.template_body
      # changeset preview not supported for stack sets

      sure?("Are you sure you want to update the #{@stack} stack set?")

      parameters = generate_all
      options = {
        stack_set_name: @stack,
        parameters: parameters,
        capabilities: capabilities, # ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
      }
      options[:tags] = tags unless tags.empty?
      set_template_url!(options)
      show_options(options, "cfn.update_stack_set")

      resp = cfn.update_stack_set(options)
      puts message unless @options[:mute]
      resp[:operation_id]
    end
  end
end
