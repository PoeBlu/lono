module Lono::Template::Strategy
  class Url < Base
    def run
      url = @options[:url]
      downloader = Lono::Cfn::Download.new(source: url)
      downloader.download_path = "#{Lono.config.output_path}/#{@blueprint}/templates/#{@blueprint}.yml"
      downloader.run
    end
  end
end
