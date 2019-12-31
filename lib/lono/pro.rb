module Lono
  class Pro < Lono::Command
    desc "blueprints", "Lists available BoltOps Pro blueprints"
    long_desc Help.text(:blueprints)
    def blueprints
      Blueprint.new(options).run
    end
  end
end
