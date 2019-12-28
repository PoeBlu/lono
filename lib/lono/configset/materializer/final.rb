module Lono::Configset::Materializer
  class Final
    def build(jades)
      puts "Materializing #{jades.map(&:name).join(", ")}..."
      GemfileBuilder.new(jades).build
    end
  end
end
