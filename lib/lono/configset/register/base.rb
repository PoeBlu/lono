# Subclasses must implement:
#
#    evaluate
#
module Lono::Configset::Register
  class Base < Lono::AbstractBase
    class_attribute :configsets
    class_attribute :validations
    class_attribute :source

    include Dsl
    include Lono::Configset::EvaluateFile

    def register
      evaluate
      jadify
    end

    def jadify
      self.class.configsets.each do |registry|
        Lono::Jade.new(registry[:name], jade_type, registry)
      end
    end

    def jade_type
      finder_class.to_s.sub('Lono::Finder::','').underscore
    end

    # Used in Base#validate!
    def finder_class
      case self
      when Lono::Configset::Register::Blueprint
        Lono::Finder::Blueprint::Configset
      when Lono::Configset::Register::Project
        Lono::Finder::Configset
      end
    end

    # Store to to be able to provide the validation errors altogether later.
    def store_for_validation(name)
      # save caller line to use later for pointing to exactly line
      caller_line = caller.grep(/evaluate_file/).first
      self.class.validations << {name: name, caller_line: caller_line}
    end

    # Validate the configset before building templates. So user finds out about errors early.
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

  public
    class << self
      def clear!
        self.configsets = []
        self.validations = []
      end

      def prepend(registry)
        self.configsets.unshift(registry) unless configsets.include?(registry)
      end
    end
  end
end
