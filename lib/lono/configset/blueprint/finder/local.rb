class Lono::Configset::Blueprint::Finder
  class Local < Lono::Configset::Blueprint::Finder
    extend Memoist

    def find(name)
      found = all.find { |i| i["name"] == name }
      return found["path"] if found
    end

    def all
      blueprint_configsets + vendor_configsets
    end

    def blueprint_configsets
      configsets("#{Lono.blueprint_root}/app/configsets", "blueprint-local")
    end

    def vendor_configsets
      configsets("#{Lono.root}/vendor/configsets", "vendor-local")
    end
  end
end
