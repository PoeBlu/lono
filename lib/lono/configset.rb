module Lono
  class Configset < Command
    long_desc Help.text("configset/new")
    New.cli_options.each do |args|
      option(*args)
    end
    register(New, "new", "new NAME", "Generates new lono configset.")

    desc "list", "Lists project configsets"
    long_desc Help.text("configset/new")
    def list
      Find.list_all
    end
  end
end
