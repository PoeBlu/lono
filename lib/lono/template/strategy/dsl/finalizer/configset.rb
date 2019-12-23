class Lono::Template::Strategy::Dsl::Finalizer
  class Configset
    extend Memoist

    def initialize(cfn, options={})
      @cfn, @options = cfn, options
      @blueprint = options[:blueprint]
    end

    def run
      combiner = Lono::Configset::Combiner.new(@options)
      metadata_map = combiner.metadata_map

      # metadata_map = Lono::Configset::Loader.combined_metadata_map(@blueprint)
      metadata_map.each do |logical_id, metadata_configset|
        resource = @cfn["Resources"][logical_id]

        unless resource
          puts "WARN: Resources.#{logical_id} not found in the template. Are you sure you are specifying the correct resource id in your configsets configs?".color(:yellow)
          next
        end

        metdata = resource["Metadata"] ||= {}
        metdata["AWS::CloudFormation::Init"] ||= {}
        unless metdata["AWS::CloudFormation::Init"].empty?
          puts "WARN: Resources.#{logical_id} already has a AWS::CloudFormation::Init".color(:yellow)
          puts "Lono processing will override it because with the configured configsets."
        end
        metdata["AWS::CloudFormation::Init"] = metadata_configset["AWS::CloudFormation::Init"]
      end

      @cfn
    end
  end
end
