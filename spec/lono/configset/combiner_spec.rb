describe Lono::Configset::Combiner do
  let(:combiner) do
    Lono::Configset::Combiner.new
  end

  def load_configset(name)
    JSON.load(IO.read("spec/fixtures/configsets/#{name}.json"))
  end

  context("example") do
    let(:configset1) { load_configset("config1") }
    let(:configset2) { load_configset("config2") }

    it "combines" do
      combiner.add("ssm",   "Instance", configset1)
      combiner.add("httpd", "Instance", configset2)
      map = combiner.combine
      json =<<~EOL
      {
        "AWS::CloudFormation::Init": {
          "configSets": {
            "default": [{"ConfigSet": "ssm"},{"ConfigSet": "httpd"}],
            "ssm": ["0_aaa1","0_aaa2"],
            "httpd": ["1_bbb1","1_bbb2"]
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
          },
          "1_bbb1": {
            "commands": {
              "test": {
                "command": "echo from-bbb1 > test2.txt"
              }
            }
          },
          "1_bbb2": {
            "commands": {
              "test": {
                "command": "echo from-bbb2 > test2.txt"
              }
            }
          }
        }
      }
      EOL
      data = map["Instance"]
      expect(data).to eq(JSON.load(json))
    end
  end
end
