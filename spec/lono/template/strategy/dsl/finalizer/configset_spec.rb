describe Lono::Template::Strategy::Dsl::Finalizer::Configset do
  let(:configset) do
    Lono::Template::Strategy::Dsl::Finalizer::Configset.new(cfn)
  end
  let(:cfn) do
    YAML.load("spec/fixtures/configsets/templates/ec2.yml")
  end

  it "adds cfn-init metadata" do
    configset.run
  end
end
