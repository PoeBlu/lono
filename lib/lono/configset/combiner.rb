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
      existing_configsets.each do |data|
        add(data[:registry], data[:metdata_configset])
      end

      Register::Blueprint.configsets.each do |registry|
        loader = Blueprint::Loader.new(registry, @options)
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
      @sets.each_with_index do |a, i|
        registry, metadata = a
        name, resource = registry[:name], registry[:resource]

        @configSets["default"] ||= []
        @configSets["default"] << {"ConfigSet" => name}

        init = metadata["AWS::CloudFormation::Init"]
        cs = init.delete("configSets") # TODO: when metadata doesnt have configSets order but is flat structure
        @configSets[name] = cs["default"].map {|c| "#{i}_#{c}" }
        init.transform_keys! { |c| "#{i}_#{c}" }
        @metadata["AWS::CloudFormation::Init"].merge!(init)
        @map[resource] = @metadata
      end
      @map
    end

    def configset
      @metadata
    end
  end
end
