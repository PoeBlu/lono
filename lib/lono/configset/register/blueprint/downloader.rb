require "bundler"

class Lono::Configset::Register::Blueprint
  class Downloader
    def initialize(options={})
      @options = options
      @blueprint = options[:blueprint]

      @configsets = Lono::Configset::Register::Blueprint.configsets
      @source = ENV["LONO_BLUEPRINT_CONFIGSET_SOURCE"] || Lono::Configset::Register::Blueprint.source
    end

    def run
      return unless @source
      puts "Downloading configsets from blueprint #{@blueprint}"
      gemfile = build_gemfile
      write(gemfile)
      bundle
    end

    def build_gemfile
      lines = []
      @configsets.each do |c|
        lines << %Q|gem "#{c[:name]}", #{source_option(c)}|
      end
      lines.join("\n") + "\n"
    end

    def source_option(c)
      if @source.include?("git@") || @source.include?("https")
        %Q|git: "#{@source}/#{c[:name]}"|
      else
        %Q|path: "#{@source}/#{c[:name]}"|
      end
    end

    def write(gemfile)
      path = "tmp/configsets/Gemfile"
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, gemfile)
    end

    def bundle
      Dir.chdir("tmp/configsets/") do
        Bundler.with_clean_env do
          system("bundler install")
        end
      end
    end
  end
end
