class Lono::Configset
  class Register < Lono::AbstractBase
    def run
      Blueprint.new(@options).run
      Project.new(@options).run
    end
  end
end
