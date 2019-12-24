describe Lono::Template::Strategy::Dsl::Finalizer::Configset do
  let(:configset) do
    Lono::Template::Strategy::Dsl::Finalizer::Configset.new(cfn)
  end
  let(:metadata_map) do
    json =<<~EOL
      {
        "AWS::CloudFormation::Init": {
          "configSets": {
            "default": [{"ConfigSet": "ssm"}],
            "ssm": ["0_aaa1","0_aaa2"]
          },
          "0_aaa1": {
            "commands": {
              "test": {
                "command": "echo from-aaa1 > test1.txt"
              }
            }
          },
          "0_aaa2": {
            "commands": {
              "test": {
                "command": "echo from-aaa2 > test1.txt"
              }
            }
          }
        }
      }
    EOL
    {"Instance" => JSON.load(json)}
  end

  context "existing multiple" do
    let(:cfn) do
      YAML.load_file("spec/fixtures/configsets/templates/ec2-multiple.yml")
    end
    it "adds cfn-init metadata" do
      allow(configset).to receive(:metadata_map).and_return(metadata_map)

      # Lono::Configset::Register::Blueprint.configsets
      cfn = configset.run
      pp cfn
    end
  end
end
