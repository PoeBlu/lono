module Lono
  class Blueprint < Command
    long_desc Help.text("blueprint/new")
    New.cli_options.each do |args|
      option(*args)
    end
    register(New, "new", "new NAME", "Generates new lono blueprint.")

    desc "list", "Lists project blueprints"
    long_desc Help.text("blueprint/new")
    def list
      Finder::Blueprint.list
    end

    desc "configsets", "List blueprints configsets"
    long_desc Help.text("blueprint/new")
    def configsets(blueprint)
      Configset::List.new(options.merge(blueprint: blueprint)).run
    end
  end
end
