module Lono::Configset::Materializer
  class Final
    def build(jades)
      puts "Final Materialization"
      GemfileBuilder.new(jades).build
    end
  end
end
