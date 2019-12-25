require "active_support/core_ext/class"

module Lono::Configset::Register
  class Base < Lono::AbstractBase
    class_attribute :configsets
    class_attribute :validations

    def self.clear!
      self.configsets = []
      self.validations = []
    end

    def configset
      self.class.configsets
    end

    def evaluate_file(path)
      return unless File.exist?(path)
      instance_eval(IO.read(path), path)
    end

    # Validate the configset at register time. So user finds out about error earlier.
    def store_for_validation(name)
      # save caller line to use later for pointing to exactly line
      caller_line = caller.grep(/evaluate_file/).first
      self.class.validations << {name: name, caller_line: caller_line}
    end

    def validate!
      errors = []
      self.class.validations.each do |state|
        configset_root = finder_class.find(state[:name]) # finder_class implemented in subclass
        errors << state unless configset_root
      end

      return if errors.empty? # all good
      show_errors_and_exit!(errors)
    end

    def show_errors_and_exit!(errors)
      errors.each do |state|
        name, caller_line = state[:name], state[:caller_line]
        puts "ERROR: Configset with name #{name} not found. Double check the configsets file.".color(:red)
        pretty_trace(caller_line)
      end
      exit 1
    end

    def pretty_trace(caller_line)
      md = caller_line.match(/(.*\.rb):(\d+):/)
      path, error_line_number = md[1], md[2].to_i

      context = 5 # lines of context
      top, bottom = [error_line_number-context-1, 0].max, error_line_number+context-1

      puts "Showing file: #{path}"
      lines = IO.read(path).split("\n")
      spacing = lines.size.to_s.size
      lines[top..bottom].each_with_index do |line_content, index|
        current_line_number = top+index+1
        if current_line_number == error_line_number
          printf("%#{spacing}d %s\n".color(:red), current_line_number, line_content)
        else
          printf("%#{spacing}d %s\n", current_line_number, line_content)
        end
      end
    end

    # DSL
    def configset(name, options={})
      o = options.merge(name: name)
      self.class.configsets << o
      store_for_validation(name)
    end

  end
end
