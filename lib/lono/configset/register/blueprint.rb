class Lono::Configset::Register
  class Blueprint < Base
    self.configsets = []
    self.validations = []
    class_attribute :source

    def run
      evaluate
      download
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

    def download
      downloader = Downloader.new(@options)
      downloader.run
    end

    # DSL
    def source(v)
      self.class.source = v
    end

    def validate!
      errors = []
      self.class.validations.each do |state|
        finder = Lono::Configset::Register::Blueprint::Finder.new(@options)
        configset_root = finder.find(state[:name])
        errors << state unless configset_root
      end

      return if errors.empty? # all good
      show_errors_and_exit!(errors)
    end
  end
end
