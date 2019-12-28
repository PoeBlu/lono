require "text-table"

module Lono::Blueprint::Configset
  class List < Lono::AbstractBase
    def run
      Lono::Template::Generator.new(@options.merge(mute: true)).run

      @final ||= []

      project = Lono::Configset::Register::Project.new(@options)
      project.register
      finder = Lono::Finder::Configset.new
      finder.list("Configsets available to project and can used with configs:") if @options[:verbose]
      puts "Configsets project is using for the #{@blueprint} blueprint:" if @options[:verbose]
      show(project.configsets, finder.find_all, "project")

      blueprint = Lono::Configset::Register::Blueprint.new(@options)
      blueprint.register
      finder = Lono::Finder::Blueprint::Configset.new
      finder.list("Configsets available to #{@blueprint} blueprint:") if @options[:verbose]
      puts "Configsets built into the blueprint:" if @options[:verbose]
      show(blueprint.configsets, finder.find_all, "blueprint")

      table = Text::Table.new
      table.head = ["Name", "Path", "Type", "From"]
      puts "Final configsets being used for #{@blueprint} blueprint:"
      @final.each do |c|
        pretty_root = c[:root].sub("#{Lono.root}/",'')
        table.rows << [c[:name], pretty_root, c[:source_type], c[:from]]
      end
      puts table
    end

    def show(configsets, all, from)
      configsets.each do |c|
        puts "    #{c[:name]}" if @options[:verbose]
        config = all.find { |config| config[:name] == c[:name] }
        next unless config
        config[:from] = from
        @final << config
      end
      puts "" if @options[:verbose]
    end
  end
end
