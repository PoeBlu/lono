class Lono::Configset
  class Preparer < Lono::AbstractBase
    def run
      regsiter
      materialize
      validate!
    end

    def regsiter
      Lono::Configset::Register::Blueprint.new(@options).run
      Lono::Configset::Register::Project.new(@options).run
    end

    def materialize
      Lono::Blueprint::Configset::Downloader.new(@options).run
    end

    def validate!
      Lono::Configset::Register::Blueprint.new(@options).validate!
      Lono::Configset::Register::Project.new(@options).validate!
    end
  end
end
