module Lono
  class AbstractBase
    extend Memoist
    include Lono::Blueprint::Root
    include Lono::Conventions

    def initialize(options={})
      reinitialize(options)
    end

    # Hack so that we can use include Thor::Base
    def reinitialize(options)
      @options = options
      Lono::ProjectChecker.check
      @stack, @blueprint, @template, @param = naming_conventions(options)
      set_blueprint_root(@blueprint)
      Lono::ProjectChecker.empty_templates
    end
  end
end
