require "text-table"

module Lono::Blueprint::Configset
  class List < Lono::AbstractBase
    def run
      final = []

      finder = Lono::Finder::Configset.new
      finder.list("Configsets available to project and can used with configs:") unless @options[:quiet]

      # Run the configsets registration logic so we can print out the ones in use
      Lono::Configset::Register::Project.new(@options).register
      puts "Configsets project is using for the #{@blueprint} blueprint:" unless @options[:quiet]
      project = Lono::Configset::Register::Project.configsets
      project.each do |c|
        puts "    #{c[:name]}" unless @options[:quiet]
        found = finder.all.find { |i| i["name"] == c[:name] }
        found["from"] = "project"
        final << found
      end
      puts "" unless @options[:quiet]

      finder = Lono::Finder::Blueprint::Configset.new
      finder.list("Configsets available to #{@blueprint} blueprint:") unless @options[:quiet]

      # Run the configsets registration logic so we can print out the ones in use
      Lono::Configset::Register::Blueprint.new(@options).register
      blueprint = Lono::Configset::Register::Blueprint.configsets
      puts "Configsets built into the blueprint and is using:" unless @options[:quiet]
      blueprint.each do |c|
        puts "    #{c[:name]}" unless @options[:quiet]
        found = finder.all.find { |i| i["name"] == c[:name] }
        found["from"] = "blueprint"
        final << found
      end
      puts "" unless @options[:quiet]

      table = Text::Table.new
      table.head = ["Name", "Path", "Type", "From"]
      puts "Final configsets being used for #{@blueprint} blueprint:"
      final.each do |c|
        table.rows << [c["name"], c["path"], c["source_type"], c["from"]]
      end
      puts table

      puts "Note: Some blueprint configsets may not show up above until they're materialized."
      puts "Use `lono generate #{@blueprint}` to materialize them."
    end
  end
end
