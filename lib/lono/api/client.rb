module Lono::Api
  class Client
    extend Memoist
    include Repos

    def http
      Proxy.new
    end
    memoize :http

    def load_json(res)
      if res.code == "200"
        JSON.load(res.body).map(&:deep_symbolize_keys)
      else
        puts "Error: "
        puts "Non-successful http response status code: #{res.code}"
        puts "headers: #{res.each_header.to_h.inspect}"
        exit 1
      end
    end
  end
end
