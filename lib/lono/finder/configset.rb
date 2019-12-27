module Lono::Finder
  class Configset < Base
    class << self
      def find_local(name)
        new.find_local(name)
      end
    end

    def type
      "configset"
    end

    def detection_path
      "lib/configset.*"
    end

    # Special method for Downloader. Does not consider materialized configsets
    def find_local(name)
      config = local.find { |c| c[:name] == name }
      return config[:root] if config
    end

    def local
      project + vendor
    end
  end
end
