class Lono::Sets
  class Deploy < Lono::Cfn::Base
    def run
      parameters = generate_all
      if stack_set_exists?(@stack)
        update(parameters)
      else
        create(parameters)
      end
    end

    def update(parameters)
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
      # exit_unless_updatable!(stack_status(@stack))

      are_you_sure?(@stack, :update)

      options = {
        stack_set_name: @stack,
        parameters: parameters,
        capabilities: capabilities, # ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
      }
      options[:tags] = tags unless tags.empty?
      set_template_url!(options)
      show_options(options, "cfn.update_stack_set")
      begin
        cfn.update_stack_set(options)
      rescue Aws::CloudFormation::Errors::ValidationError => e
        puts "ERROR: #{e.message}".color(:red)
        false
      end

      puts message unless @options[:mute]
    end

    def create(parameters)
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
