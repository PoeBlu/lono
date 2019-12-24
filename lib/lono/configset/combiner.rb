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
      puts "Register::Blueprint.configsets #{Register::Blueprint.configsets}"

      Register::Project.configsets.each do |c|
        puts "metadata_map c #{c}"
        loader = Loader.new(c, @options)
        metdata_configset = loader.load
        # puts "metdata_configset #{metdata_configset}"
        if metdata_configset
          add(c, metdata_configset)
        else
          puts "WARN: metdata_configset is nil!!!".color(:yellow)
        end
      end
      # puts "@sets #{@sets}".color(:purple)
      combine
      Register::Project.clear! # in case of lono generate for all templates
      @map
    end
  end
end
