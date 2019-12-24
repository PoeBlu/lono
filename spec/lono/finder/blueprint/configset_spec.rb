describe Lono::Finder::Blueprint::Configset do
  let(:configset) { Lono::Finder::Blueprint::Configset.new(lono_root: lono_root, blueprint_root: blueprint_root) }
  let(:lono_root) { nil }
  let(:blueprint_root) { nil }

  context "project local" do
    let(:blueprint_root) { "spec/fixtures/finder/blueprint-configset/blueprint_only" }
    it "find" do
      root_path = configset.find("ssm")
      expect(root_path).to include "blueprint_only/app/configsets/ssm"
      root_path = configset.find("non-existing")
      expect(root_path).to be nil
    end
  end

  context "vendor local" do
    let(:lono_root) { "spec/fixtures/finder/blueprint-configset/vendor_only" }
    it "find" do
      root_path = configset.find("ssm")
      expect(root_path).to include "vendor_only/vendor/configsets/ssm"
    end
  end

  context "materialized local" do
    let(:lono_root) { "spec/fixtures/finder/blueprint-configset/materialized_only" }
    it "find" do
      allow(configset).to receive(:gem_roots).and_return(["spec/fixtures/finder/blueprint-configset/materialized_only"])

      root_path = configset.find("ssm")
      expect(root_path).to include "materialized_only/tmp/configsets/ssm"
    end
  end

  context "both blueprint and vendor" do
    let(:blueprint_root) { "spec/fixtures/finder/blueprint-configset/both" }
    let(:lono_root) { "spec/fixtures/finder/blueprint-configset/both" }
    it "find higher precedence project local" do
      root_path = configset.find("ssm")
      expect(root_path).to include "both/app/configsets/ssm"
    end
  end
end
