module Lono::Configset::Register
  class Base < Lono::AbstractBase
    include Lono::Configset::EvaluateFile

    class_attribute :configsets
    class_attribute :validations
    class_attribute :source

    include Dsl

    class << self
      def clear!
        self.configsets = []
        self.validations = []
      end

      def prepend(registry)
        self.configsets.unshift(registry) unless configsets.include?(registry)
      end
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
        config = finder_class.find(state[:name]) # finder_class implemented in subclass
        errors << state unless config
      end

      return if errors.empty? # all good
      show_errors_and_exit!(errors)
    end

    def show_errors_and_exit!(errors)
      errors.each do |state|
        name, caller_line = state[:name], state[:caller_line]
        puts "ERROR: Configset with name #{name} not found. Double check the Gemfile and configs/#{@blueprint}/configsets files.".color(:red)
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
  end
end
