module Lono::Configset::Materializer
  class Final
    def build(jades)
      list = jades.map(&:name).uniq.join(", ") # possible to have different versions. only showing names and removing duplicates
      puts "Materializing #{list}..."
      GemfileBuilder.new(jades).build
    end
  end
end
