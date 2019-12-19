require "fileutils"
require "memoist"
require "thor"
require "yaml"

# Subclasses should implement:
#
#   variables - Returns String with content of varibles files.
#   setup - Hook to do extra things like create IAM service roles.
#   finish - Finish hook after config files have been created.
#
# Note there is no params method to hook. The Base class handles params well.
#
class Lono::Seed
  class Base < Lono::AbstractBase
    include Lono::AwsServices
    include ServiceRole

    # What's needed for a Thor::Group or "Sequence"
    # Gives us Thor::Actions commands like create_file
    include Thor::Actions
    include Thor::Base
    # Override Thor::Base initialize
    def initialize(options={})
      reinitialize(options)
    end

    extend Memoist

    def run
      generate_template
      @output_template = Lono::OutputTemplate.new(@blueprint, @template)
      setup
      self.destination_root = Dir.pwd # Thor::Actions require destination_root to be set
      create_params
      create_variables
      finish
    end

    def generate_template
      Lono::Template::Generator.new(@options).run
    end

    def create_params
      return unless params
      create_param_file
    end

    def create_param_file
      lines = []
      required = @output_template.required_parameters
      lines << "# Required parameters:" unless required.empty?
      required.each do |name, data|
        example = description_example(data["Description"])
        lines << "#{name}=#{example}"
      end
      optional = @output_template.optional_parameters
      lines << "# Optional parameters:" unless optional.empty?
      optional.each do |name, data|
        value = default_value(data)
        lines << "# #{name}=#{value}"
      end

      if lines.empty?
        puts "Template has no parameters."
        return
      end

      content = lines.join("\n") + "\n"
      dest_path = "configs/#{@blueprint}/params/#{Lono.env}.txt" # only support environment level parameters for now
      create_file(dest_path, content) # Thor::Action
    end

    def params
      true
    end

    def create_variables
      return unless variables
      dest_path = "configs/#{@blueprint}/variables/#{Lono.env}.rb"
      create_file(dest_path, variables) # Thor::Action
    end

    def setup; end
    def finish; end

    # Meant to be overriden by subclass
    # Return String with contents of variables file.
    def variables
      false
    end

    def description_example(description)
      default = ''
      return default unless description
      md = description.match(/(Example|IE): (.*)/)
      return default unless md
      md[2]
    end

    def default_value(data)
      value = data["Default"]
      # Dont use !blank? since there can be false optional values
      # Also dont use .empty? since value can be an Integer
      if value.nil? || value == ''
        description_example(data["Description"])
      else
        value
      end
    end
  end
end
