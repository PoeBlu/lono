require "yaml"

module Lono::Configset
  class Combiner
    def initialize
      @sets = []
      @metadata = {"AWS::CloudFormation::Init" => {"configSets" => {}}}
      @configSets = @metadata["AWS::CloudFormation::Init"]["configSets"]
    end

    def add(name, resource, configset)
      @sets << [name, resource, configset.dup]
    end

    def combine
      @sets.each_with_index do |a, i|
        name, _, configset = a
        @configSets["default"] ||= []
        @configSets["default"] << {"ConfigSet" => name}
        init = configset["AWS::CloudFormation::Init"]
        cs = init.delete("configSets") # TODO: handle cases when configset doesnt have configSet order but is flat structure
        @configSets[name] = cs["default"].map {|c| "#{i}_#{c}" }
        init.transform_keys! { |c| "#{i}_#{c}" }
        @configSets.merge!(init)
      end
      @metadata
    end

    def configset
      @metadata
    end
  end
end
