module Lono::Api
  class Client
    extend Memoist
    include Blueprints

    def http
      Proxy.new
    end
    memoize :http

    # Lono::API does not include the /. IE: localhost:8888
    # path includes the /. IE: "/blueprints"
    def url(path)
      "#{Lono::API}#{path}"
    end
  end
end
