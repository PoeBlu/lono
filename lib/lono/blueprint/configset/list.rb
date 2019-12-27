require "text-table"

module Lono::Blueprint::Configset
  class List < Lono::AbstractBase
    def run
      @final ||= []

      project = Lono::Configset::Register::Project.new(@options)
      project.register
      finder = Lono::Finder::Configset.new
      finder.list("Configsets available to project and can used with configs:") unless @options[:quiet]
      puts "Configsets project is using for the #{@blueprint} blueprint:" unless @options[:quiet]
      show(project.configsets, finder.all, "project")

      blueprint = Lono::Configset::Register::Blueprint.new(@options)
      blueprint.register
      finder = Lono::Finder::Blueprint::Configset.new
      finder.list("Configsets available to #{@blueprint} blueprint:") unless @options[:quiet]
      puts "Configsets built into the blueprint:" unless @options[:quiet]
      show(blueprint.configsets, finder.all, "blueprint")

      table = Text::Table.new
      table.head = ["Name", "Path", "Type", "From"]
      puts "Final configsets being used for #{@blueprint} blueprint:"
      @final.each do |c|
        table.rows << [c[:name], c[:root], c[:source_type], c[:from]]
      end
      puts table

      puts "Note: Some blueprint configsets may not show up above until they're materialized."
      puts "Use `lono generate #{@blueprint}` to materialize them."
    end

    def show(configsets, all, from)
      configsets.each do |c|
        puts "    #{c[:name]}" unless @options[:quiet]
        config = all.find { |config| config[:name] == c[:name] }
        next unless config
        config[:from] = from
        @final << config
      end
      puts "" unless @options[:quiet]
    end
  end
end
