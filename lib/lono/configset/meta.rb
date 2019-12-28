class Lono::Configset
  class Meta
    extend Memoist
    include EvaluateFile
    include Dsl

    class_attribute :registries
    self.registries = []

    def initialize(jade)
      @jade = jade
    end

    def evaluate
      path = "#{@jade.root}/lib/meta.rb"
      puts "evaluate_file path #{path}"
      evaluate_file(path) # DSL depends_on sets @jade.depends_on decorated options
    end
  end
end
