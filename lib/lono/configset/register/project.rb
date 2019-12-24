module Lono::Configset::Register
  class Project < Base
    self.configsets = []
    self.validations = []

    def register
      evaluate
    end

    def evaluate
      location = Lono::ConfigLocation.new("configsets", @options, Lono.env)
      evaluate_file(location.lookup_base) if location.lookup_base
      evaluate_file(location.lookup) if location.lookup # config file
    end

    # Used in Base#validate!
    def finder_class
      Lono::Finder::Configset
    end
  end
end
