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
      found = local.find { |i| i["name"] == name }
      return found["path"] if found
    end

    def local
      project + vendor
    end
  end
end
