require "yaml"

class Lono::Configset
  class Combiner
    def initialize(options={})
      @options = options

      @sets = []
      @metadata = {"AWS::CloudFormation::Init" => {"configSets" => {}}}
      @configSets = @metadata["AWS::CloudFormation::Init"]["configSets"]
      @map = {} # stores resource logical id => metadata cfn-init
    end

    def add(options, metadata)
      @sets << [options, metadata.dup]
    end

    def combine
      @sets.each_with_index do |a, i|
        options, metadata = a
        name, resource = options[:name], options[:resource]

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

    ########
    def metadata_map
      Register::Blueprint.configsets.each do |c|
        loader = Blueprint::Loader.new(c, @options)
        add(c, loader.metdata_configset)
      end
      Register::Project.configsets.each do |c|
        loader = Loader.new(c, @options)
        add(c, loader.metdata_configset)
      end

      combine
      Register::Blueprint.clear! # in case of lono generate for all templates
      Register::Project.clear! # in case of lono generate for all templates
      @map
    end
  end
end
