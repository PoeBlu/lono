class Lono::Template::Strategy::Dsl
  class Finalizer
    def initialize(cfn, parameters)
      @cfn, @parameters = cfn, parameters
    end

    def run
      puts "Finalizer @parameters #{@parameters}"
      @cfn
    end
  end
end
