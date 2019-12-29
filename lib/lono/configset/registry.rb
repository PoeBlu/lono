class Lono::Configset
  class Registry
    attr_reader :args, :options
    attr_accessor :caller_line, :parent, :depends_on
    def initialize(args, options)
      @args, @options = args, options
    end

    def name
      @args.first
    end

    def resource
      @options[:resource]
    end

    def resource=(v)
      @options[:resource] = v
    end
  end
end
