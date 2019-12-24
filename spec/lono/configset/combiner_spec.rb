describe Lono::Configset::Combiner do
  let(:combiner) do
    Lono::Configset::Combiner.new(cfn)
  end

  def load_configset(name)
    JSON.load(IO.read("spec/fixtures/configsets/#{name}"))
  end
  def load_template(name)
    YAML.load(IO.read("spec/fixtures/configsets/templates/#{name}"))
  end

  context("no existing metadata") do
    let(:cfn)  { load_template("ec2-no-metadata.yml") }
    let(:configset1) { load_configset("config1.json") }
    let(:configset2) { load_configset("config2.json") }

    it "combines" do
      combiner.add({name: "ssm", resource: "Instance"}, configset1)
      combiner.add({name: "httpd", resource: "Instance"}, configset2)
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

  context("existing metadata multiple configsets") do
    let(:cfn)  { load_template("ec2-multiple.yml") }
    let(:configset1) { load_configset("config1.json") }
    let(:configset2) { load_configset("config2.json") }

    it "combines" do
      combiner.existing_configsets.each do |data|
        combiner.add(data[:registry], data[:metdata_configset])
      end
      combiner.add({name: "ssm", resource: "Instance"}, configset1)
      map = combiner.combine
      data = map["Instance"]
      json =<<~EOL
        {
          "AWS::CloudFormation::Init": {
            "configSets": {
              "default": [
                {
                  "ConfigSet": "original"
                },
                {
                  "ConfigSet": "ssm"
                }
              ],
              "original": [
                "0_existing"
              ],
              "ssm": [
                "1_aaa1",
                "1_aaa2"
              ]
            },
            "0_existing": {
              "commands": {
                "test": {
                  "command": "echo existing >> /tmp/test.txt"
                }
              }
            },
            "1_aaa1": {
              "commands": {
                "test": {
                  "command": "echo from-aaa1 > test1.txt"
                }
              }
            },
            "1_aaa2": {
              "commands": {
                "test": {
                  "command": "echo from-aaa2 > test1.txt"
                }
              }
            }
          }
        }
      EOL
      expect(data).to eq(JSON.load(json))
    end
  end
end
