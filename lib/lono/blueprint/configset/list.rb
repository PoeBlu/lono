module Lono::Blueprint::Configset
  class List < Lono::AbstractBase
    def run
      Lono::Finder::Blueprint::Configset.list

      # Run the configsets registration logic so we can print out the ones in use
      puts "Some blueprint configsets may not show up above until they're materialized."
      puts "Use `lono generate #{@blueprint}` to materialize them."
      puts "Configsets in use:"
      Lono::Configset::Register::Blueprint.new(@options).register
      Lono::Configset::Register::Blueprint.configsets.each do |c|
        puts c[:name]
      end
    end
  end
end
