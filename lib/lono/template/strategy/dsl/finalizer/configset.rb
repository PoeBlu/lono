class Lono::Template::Strategy::Dsl::Finalizer
  class Configset
    extend Memoist

    def initialize(cfn, options={})
      @cfn, @options = cfn, options
      @blueprint = options[:blueprint]
    end

    def run
      metadata_map.each do |logical_id, metadata_configset|
        resource = @cfn["Resources"][logical_id]

        unless resource
          puts "WARN: Resources.#{logical_id} not found in the template. Are you sure you are specifying the correct resource id in your configsets configs?".color(:yellow)
          next
        end

        metdata = resource["Metadata"] ||= {}
        metdata["AWS::CloudFormation::Init"] ||= {}
        # The metadata_configset has been combined with the original AWS::CloudFormation::Init if it exists
        metdata["AWS::CloudFormation::Init"] = metadata_configset["AWS::CloudFormation::Init"]
      end

      @cfn
    end

    def metadata_map
      combiner = Lono::Configset::Combiner.new(@cfn, @options)
      combiner.metadata_map
    end
    memoize :metadata_map
  end
end
