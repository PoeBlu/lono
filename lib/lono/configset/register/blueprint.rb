module Lono::Configset::Register
  class Blueprint < Base
    self.configsets = []
    self.validations = []
    class_attribute :source

    def run
      evaluate
    end

    def evaluate
      path = find_configsets
      return unless path
      evaluate_file(path)
    end

    def find_configsets
      path = "#{Lono.blueprint_root}/config/configsets.rb"
      path if File.exist?(path)
    end

    # DSL
    def source(v)
      self.class.source = v
    end

    # Used in Base#validate!
    def finder_class
      Lono::Finder::Blueprint::Configset
    end
  end
end
