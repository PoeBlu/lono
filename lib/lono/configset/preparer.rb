class Lono::Configset
  class Preparer < Lono::AbstractBase
    def initialize(options={})
      super
      @blueprint = Register::Blueprint.new(options)
      @project   = Register::Project.new(options)
      @meta      = Meta.new(options)
    end

    def run
      register
      puts "hi2"
      materialize_jades
      puts "hi3"
      resolve_dependencies
      puts "hi4 EXIT EARLY"
      exit
      # validate_all!
    end

    # Create configsets registry items
    def register
      @project.register
      @blueprint.register
    end

    def materialize_jades
      # Create lazy jades
      Register::Blueprint.configsets.each do |registry|
        Lono::Jade.new(registry[:name], "blueprint")
      end
      Register::Project.configsets.each do |registry|
        Lono::Jade.new(registry[:name], "configset")
      end
      # Materialize current jades
      Lono::Jade.tracked do |jade|
        jade.materialize
      end
    end

    def resolve_dependencies
      jades = Lono::Jade.tracked
      Dependencies.new.resolve(jades)
    end

    def download
      Lono::Blueprint::Configset::Downloader.new(@options).run
    end

    def validate_all!
      @blueprint.validate!
      @project.validate!
    end
  end
end
