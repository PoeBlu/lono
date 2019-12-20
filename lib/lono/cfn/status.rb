class Lono::Cfn
  class Status < CfnStatus
    def initialize(options={})
      super(options[:stack], options)
    end
  end
end
