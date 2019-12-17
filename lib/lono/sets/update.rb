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

      param_preview.run
      codediff_preview.run
      # changeset preview not supported for stack sets

      options = build_options
      show_options(options, "cfn.update_stack_set")

      sure?("Are you sure you want to update the #{@stack} stack set?")

      resp = cfn.update_stack_set(options)
      puts message unless @options[:mute]
      resp[:operation_id]
    end

    def codediff_preview
      Lono::Sets::Preview::Codediff.new(@options.merge(mute_params: true, mute_using: true))
    end
    memoize :codediff_preview

    def param_preview
      Lono::Sets::Preview::Param.new(@options)
    end
    memoize :param_preview
  end
end
