class Lono::Template::Strategy::Dsl::Finalizer
  class Configset
    extend Memoist

    def initialize(cfn)
      @cfn = cfn
    end

    def run
      puts "Finalizer Configset".color(:purple)
      pp Lono::Configset::Register.configsets

      # lookup configset path - blueprints or configsets
      # load the JSON from file
      # decorate @cfn

      @cfn
    end
  end
end
