require "active_support/core_ext/class"

class Lono::Configset
  class Metadata < Lono::AbstractBase
    extend Memoist
    include EvaluateFile
    include Dsl

    class_attribute :registries
    self.registries = []

    def register
      configsets.each do |registry|
        @finder_class = finder_class_for(registry[:from_registry_class])
        config = @finder_class.find(registry[:name])
        @parent_configset = config["name"] # must be set here for depends_on to see
        path = "#{config["root"]}/lib/metadata.rb"
        evaluate_file(path)
      end
    end

    def metas
      puts "registries:".color(:yellow)
      pp self.class.registries
      []
    end

    # configset registry entries
    def configsets
      Lono::Configset::Register::Blueprint.configsets +
      Lono::Configset::Register::Project.configsets
    end

    def configset_name(root)
      "#{root}/.meta/config.yml"
    end

    def finder_class_for(from_registry_class)
      # Note: With an instance the case statement does not match without to_s, even though the object_id matches.
      # Not passing instance so there's less verbose info for debugging.
      case from_registry_class.to_s
      when "Lono::Configset::Register::Blueprint"
        Lono::Finder::Blueprint::Configset
      when "Lono::Configset::Register::Project"
        Lono::Finder::Configset
      else
        raise "Should never reach here. from_registry_class #{from_registry_class} is not one that is supported"
      end
    end
  end
end
