module Lono
  class Configset < Command
    long_desc Help.text("configset/new")
    New.cli_options.each do |args|
      option(*args)
    end
    register(New, "new", "new NAME", "Generates new lono configset.")

    desc "list", "Lists project configsets"
    long_desc Help.text("configset/list")
    def list
      Finder::Configset.list(filter_materialized: true)
    end
  end
end
