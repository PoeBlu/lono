require "active_support/core_ext/class"

class Lono::Configset
  class Metadata < Lono::AbstractBase
    extend Memoist
    include EvaluateFile
    include Dsl

    class_attribute :registry
    self.registry = []

    def register
      configsets.each do |registry|
        puts "registry: #{registry}"
        path = find_metadata(registry)
        evaluate_file(path)
      end

      puts "self.class.registry #{self.class.registry}"
    end

    # configset registry entries
    def configsets
      Lono::Configset::Register::Blueprint.configsets +
      Lono::Configset::Register::Project.configsets
    end

    def find_metadata(registry)
      finder = finder_class_for(registry[:from_registry_class])
      config = finder.find(registry[:name])
      @configset_name = config["name"]
      puts "@configset_name #{@configset_name}"
      "#{config["root"]}/lib/metadata.rb"
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
