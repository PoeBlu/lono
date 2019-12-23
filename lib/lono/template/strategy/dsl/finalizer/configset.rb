class Lono::Template::Strategy::Dsl::Finalizer
  class Configset
    extend Memoist

    def initialize(cfn)
      @cfn = cfn
    end

    def run
      puts "Finalizer Configset".color(:purple)

      metadata_map = Lono::Configset::Loader.combined_metadata_map
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
        metdata["AWS::CloudFormation::Init"] = metadata_configset
      end

      @cfn
    end
  end
end
