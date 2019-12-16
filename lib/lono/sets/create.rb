class Lono::Sets
  class Create < Base
    def save
      message = "Creating #{@stack.color(:green)} stack set."
      if @options[:noop]
        puts "NOOP #{message}"
        return
      end

      # delete_rollback_stack_set # TODO

      if stack_set_exists?(@stack)
        puts "Cannot create #{@stack.color(:green)} stack set because it already exists.".color(:red)
        return
      end

      unless File.exist?(template_path)
        puts "Cannot create #{@stack.color(:green)} template not found: #{template_path}."
        return
      end

      parameters = generate_all
      options = {
        stack_set_name: @stack,
        parameters: parameters,
        capabilities: capabilities, # ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
      }
      options[:tags] = tags unless tags.empty?
      set_template_url!(options)

      show_options(options, "cfn.create_stack_set")
      cfn.create_stack_set(options)
      # TODO: add rescues.. but should be same as update, this is handled in a class in cfn
      puts message unless @options[:mute]
    end
  end
end