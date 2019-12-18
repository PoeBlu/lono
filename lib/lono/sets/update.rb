class Lono::Sets
  class Update < Base
    def save
      message = "Updating #{@stack} stack set"
      if @options[:noop]
        puts "NOOP #{message}"
        return
      end

      unless stack_set_exists?(@stack)
        puts "ERROR: Cannot update a stack set because #{@stack} does not exists.".color(:red)
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
      operation_id = resp[:operation_id]
      puts message unless @options[:mute]

      return true unless @options[:wait]
      status = Status.new(@stack, operation_id)
      success = status.wait unless @options[:noop]
      unless success
        summaries_errors(operation_id)
        exit 1
      end
      success
    end

    def summaries_errors(operation_id)
      puts "Stack Set Operation Summaries errors:"
      resp = cfn.list_stack_set_operation_results(stack_set_name: @stack, operation_id: operation_id)
      resp.summaries.each do |s|
        data = {
          account: s.account,
          region: s.region,
          status: s.status,
          "status reason": s.status_reason,
        }
        message = data.inject("") do |text, (k,v)|
          text += [k.to_s.color(:purple), v].join(" ") + " "
        end
        puts message
      end
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
