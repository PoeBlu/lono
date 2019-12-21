module Lono::Template::Strategy::Dsl::Builder::Section
  module Extensions
    def parameter_group(label)
      @group_label = label
      yield
      @group_label = nil
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
