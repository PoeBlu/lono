require "yaml"

class Lono::Configset
  class Combiner
    def initialize(cfn, options={})
      @cfn, @options = cfn, options

      @sets = []
      @metadata = {"AWS::CloudFormation::Init" => {"configSets" => {}}}
      @configSets = @metadata["AWS::CloudFormation::Init"]["configSets"]
      @map = {} # stores resource logical id => metadata cfn-init
    end

    def metadata_map
      return {} unless additional_configsets?

      existing_configsets.each do |data|
        add(data[:registry], data[:metdata_configset])
      end

      Register::Blueprint.configsets.each do |registry|
        loader = Lono::Blueprint::Configset::Loader.new(registry, @options)
        add(registry, loader.metdata_configset)
      end
      Register::Project.configsets.each do |registry|
        loader = Loader.new(registry, @options)
        add(registry, loader.metdata_configset)
      end

      combine
      Register::Blueprint.clear! # in case of lono generate for all templates
      Register::Project.clear! # in case of lono generate for all templates
      @map
    end

    def add(registry, metadata)
      @sets << [registry, metadata.dup]
    end

    def additional_configsets?
      !Register::Blueprint.configsets.empty? || !Register::Project.configsets.empty?
    end

    # Normalized/convert cfn template to mimic the registry format
    def existing_configsets
      configsets = []
      @cfn["Resources"].each do |logical_id, attributes|
        init = attributes.dig("Metadata", "AWS::CloudFormation::Init")
        next unless init
        data = {
          registry: {name: "original", resource: logical_id},
          metdata_configset: attributes["Metadata"]
        }
        configsets << data
      end
      configsets
    end

    def combine
      # Remove duplicate configsets. Can happen if same configset is in blueprint and project.
      # Ugly because of the sets structure.
      @sets.uniq! do |array|
        registry, _ = array
        registry.name
      end

      @sets.each_with_index do |array, i|
        padded_i = "%03d" % i
        registry, metadata = array
        name, resource = registry.name, registry.resource

        @configSets["default"] ||= []
        @configSets["default"] << {"ConfigSet" => name}

        init = metadata["AWS::CloudFormation::Init"]

        if init.key?("configSets")
          cs = init.delete("configSets") # Only support configSets with simple Array of Strings
          validate_simple!(registry, cs)
          @configSets[name] = cs["default"].map {|c| "#{padded_i}_#{c}" }
          init.transform_keys! { |c| "#{padded_i}_#{c}" }
        else # simple config
          config_key = "#{padded_i}_single_generated"
          @configSets[name] = [config_key]
          init = {config_key => init["config"]}
        end

        @metadata["AWS::CloudFormation::Init"].merge!(init)
        @map[resource] = @metadata
      end
      @map
    end

    def validate_simple!(registry, cs)
      has_complex_type = cs["default"].detect { |s| !s.is_a?(String) }
      if has_complex_type
        message =<<~EOL
          ERROR: The configset #{registry.name} has a configSets property with a complex type.
          configSets:

              #{cs}

          lono configsets only supports combining configSets with an Array of Strings.
        EOL
        if ENV['LONO_TEST']
          raise message
        else
          puts message.color(:red)
          exit 1
        end
      end
    end

    def configset
      @metadata
    end
  end
end
