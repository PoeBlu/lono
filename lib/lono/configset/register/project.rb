class Lono::Configset::Register
  class Project < Base
    self.configsets = []
    self.validations = []

    def run
      evaluate
    end

    def evaluate
      options = ActiveSupport::HashWithIndifferentAccess.new(@options.dup)
      options[:blueprint] = @blueprint
      options[:stack] ||= @blueprint

      location = Lono::ConfigLocation.new("configsets", options, Lono.env)
      evaluate_file(location.lookup_base) if location.lookup_base
      evaluate_file(location.lookup) if location.lookup # config file
    end
  end
end
