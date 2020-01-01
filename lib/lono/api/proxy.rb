# To allow a pretty interface:
#
#     res = http.get("/blueprints")
#
module Lono::Api
  class Proxy
    extend Memoist

    def get(path)
      url = url(path)
      http = http(url)
      req = request(Net::HTTP::Get, url,
        lono_version: Lono::VERSION,
        lono_command: lono_command,
      )
      http.request(req) # send request
    end

    def http(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = http.read_timeout = 30
      http.use_ssl = true if uri.scheme == 'https'
      http
    end
    memoize :http

    def request(klass, url, data)
      req = klass.new(url) # url includes query string and uri.path does not, must used url
      text = JSON.dump(data)
      req.body = text
      req.content_length = text.bytesize
      req
    end

    # Lono::API does not include the /. IE: localhost:8888
    # path includes the /. IE: "/blueprints"
    def url(path)
      "#{Lono::API}#{path}"
    end

  private
    def lono_command
      "#{$0} #{ARGV.join(' ')}"
    end
  end
end