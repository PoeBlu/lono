module Lono::Template::Strategy::Dsl::Builder::Section
  module Extensions
    def parameter_group(label)
      @parameter_group_label = label
      puts "parameter_group label #{label}"
      yield
      @parameter_group_label = nil
    end

    # Decorate the parameter method to make smarter.
    def parameter(*definition)
      puts "parameter Builder::Helpers::ParamHelper @label #{@label} self #{self}".color(:cyan)
      name, second, third = definition
      create_condition = nil
      # medium form
      if definition.size == 2 && second.is_a?(Hash)
        puts "1"
        # Creates:
        #
        #    1. parameter
        #    2. condition - used to make it optional
        #
        create_condition = second.key?(:Conditional)
        options = normalize_conditional_parameter_options(second)
        super(name, options)
      # medium form 2 - the argument is the default
      elsif definition.size == 3 && !second.is_a?(Hash) && third.is_a?(Hash)
        puts "2"
        create_condition = third.key?(:Conditional)
        options = normalize_conditional_parameter_options(third)
        options[:Default] = second # probably a String, Integer, or Float
        super(name, options)
      else
        puts "3"
        super
        create_condition = false
      end

      condition("Has#{name}", not!(equals(ref(name), ""))) if create_condition
    end

    # use long name to minimize method name collision
    def normalize_conditional_parameter_options(options)
      if options.is_a?(Hash)
        options.delete(:Conditional)
        options = if options.empty?
          { Default: "" }
        else
          defaults = { Default: "" }
          options.reverse_merge(defaults)
        end
      end

      options
    end

    # Creates:
    #
    #    1. parameter
    #    2. condition - used to make it optional
    #
    def conditional_parameter(name, options={})
      puts "DEPRECATED: Will be removed. Instead use: parameter(name, Conditional: true)"
      options = normalize_conditional_parameter_options(options)
      parameter(name, options)
      condition("Has#{name}", not!(equals(ref(name), "")))
    end

    def optional_ref(name)
      puts "DEPRECATED: Will be removed. Instead use: ref(name, Conditional: true)"
      if!("Has#{name}", ref(name), ref("AWS::NoValue"))
    end
  end
end
