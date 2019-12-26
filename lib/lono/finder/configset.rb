module Lono::Finder
  class Configset < Base
    def type
      "configset"
    end

    def detection_path
      "lib/configset.*"
    end

    # Special method for Downloader. Does not consider materialized configsets
    def find_local(name)
      jade = local.find { |j| j.name == name }
      return jade.path if jade
    end

    def local
      project + vendor
    end
  end
end
