module Lono::Api
  module Blueprints
    def blueprints
      url = url("/blueprints")
      res = http.get(url)

      if res.code == "200"
        data = JSON.load(res.body)
        puts data
      else
        puts "Error: "
        puts "Non-successful http response status code: #{res.code}"
        puts "headers: #{res.each_header.to_h.inspect}"
        exit 1
      end
    end
  end
end
