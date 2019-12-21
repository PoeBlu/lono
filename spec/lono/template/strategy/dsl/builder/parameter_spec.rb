describe Lono::Template::Strategy::Dsl::Builder::Parameter do
  let(:parameter) { Lono::Template::Strategy::Dsl::Builder::Parameter.new("ec2", definition) }

  context "short form without default" do
    let(:definition) do
      [ :ami_id ]
    end

    it "produces template" do
      parameter.template
      result = parameter.template
      expect(result).to eq(
        {"AmiId"=>{"Type"=>"String"}}
      )
    end
  end

  context "short form with default" do
    let(:definition) do
      [ :ami_id, "ami-111" ]
    end

    it "produces template" do
      parameter.template
      result = parameter.template
      expect(result).to eq(
        {"AmiId"=>{"Default"=>"ami-111", "Type"=>"String"}}
      )
    end
  end

  context "medium form" do
    let(:definition) do
      [ :company, { default: "boltops", description: "instance type" } ]
    end

    it "produces template" do
      parameter.template
      result = parameter.template
      expect(result).to eq(
        {"Company"=>{"Default"=>"boltops", "Description"=>"instance type", "Type"=>"String"}}
      )
    end
  end

  context "long form" do
    let(:definition) do
      [ company: { default: "boltops", description: "instance type" } ]
    end

    it "produces template" do
      parameter.template
      result = parameter.template
      expect(result).to eq(
        {"Company"=>{"Default"=>"boltops", "Description"=>"instance type", "Type"=>"String"}}
      )
    end
  end

  context "conditional option" do
    let(:definition) do
      [ "InstanceType", { Conditional: true } ]
    end

    it "produces template" do
      parameter.template
      result = parameter.template
      expect(result).to eq(
        {"InstanceType"=>{"Default"=>"", "Type"=>"String"}}
      )
    end
  end
end
