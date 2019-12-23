class Lono::Template::Strategy::Dsl
  class Finalizer
    def initialize(cfn, options={})
      @cfn, @options = cfn, options
    end

    def run
      @cfn = ParameterGroups.new(@cfn, @options[:parameters]).run
      @cfn = Configset.new(@cfn, @options).run
      @cfn
    end
  end
end
