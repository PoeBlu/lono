describe Lono::Configset::Loader do
  let(:loader) do
    Lono::Configset::Loader.new(options)
  end

  context("example") do
    let(:options) { { name: "ssm", resource: "Instance" } }
    it "loads metadata" do
      data = loader.load
      expect(data).to be_a(Hash)
      init_key = data.key?("AWS::CloudFormation::Init")
      expect(init_key).to be true
    end
  end
end
