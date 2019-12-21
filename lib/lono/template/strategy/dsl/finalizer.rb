class Lono::Template::Strategy::Dsl
  class Finalizer
    def initialize(cfn, options={})
      @cfn, @options = cfn, options
    end

    def run
      ParameterGroups.new(@cfn, @options[:parameters]).run
    end
  end
end
