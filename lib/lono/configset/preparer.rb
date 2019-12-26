class Lono::Configset
  class Preparer < Lono::AbstractBase
    def initialize(options={})
      super
      @blueprint = Register::Blueprint.new(options)
      @project   = Register::Project.new(options)
      @meta      = Meta.new(options)
    end

    def run
      puts "hi1"
      register
      puts "hi2"
      materialize_jades
      puts "hi3"
      resolve_dependencies
      puts "hi4"
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
        Lono::Blueprint::Configset::Jade.get(registry[:name])
      end
      Register::Project.configsets.each do |registry|
        Lono::Configset::Jade.get(registry[:name])
      end
      # Materialize current jades
      Lono::Jade.tracked.each do |name, jade|
        jade.materialize
      end
    end

    def resolve_dependencies
      jades = Lono::Jade.tracked.values
      puts "resolve_dependencies 1 jades #{jades.map(&:name)}"
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
