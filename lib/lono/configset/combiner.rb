require "yaml"

class Lono::Configset
  class Combiner
    def initialize
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
  end
end