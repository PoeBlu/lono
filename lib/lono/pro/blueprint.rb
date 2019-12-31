class Lono::Pro
  class Blueprint < Base
    def run
      puts "Available BoltOps Pro blueprints"
      puts api.blueprints
    end
  end
end
