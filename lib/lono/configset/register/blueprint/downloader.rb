require "bundler"

class Lono::Configset::Register::Blueprint
  class Downloader
    extend Memoist

    def initialize(options={})
      @options = options
      @blueprint = options[:blueprint]
      @configsets = Lono::Configset::Register::Blueprint.configsets
    end

    def source
      Source.new
    end
    memoize :source

    def run
      return if @configsets.empty?
      puts "Downloading configsets from blueprint #{@blueprint}"
      clean_gemfile
      gemfile = build_gemfile
      return unless gemfile
      write(gemfile)
      bundle
    end

    def build_gemfile
      lines = []
      @configsets.each do |c|
        next if local_configset?(c[:name])
        options = source.options(c)
        args = options.inject([]) { |r,(k,v)| r << %Q|#{k}: "#{v}"| }.join(', ')
        lines << %Q|gem "#{c[:name]}", #{args}|
      end
      lines.join("\n") + "\n"
    end

    def local_configset?(name)
      finder = Finder.new(@options)
      !!finder.find_local(name)
    end

    def write(gemfile)
      path = "tmp/configsets/Gemfile"
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, gemfile)
    end

    def bundle
      Dir.chdir("tmp/configsets/") do
        Bundler.with_clean_env do
          sh("bundler install")
        end
      end
    end

    def sh(command)
      puts "=> #{command}"
      system(command)
      unless $?.success?
        puts "FAILED: #{command}".color(:red)
        exit 1
      end
    end

    def clean_gemfile
      FileUtils.rm_f("tmp/configsets/Gemfile")
    end
  end
end
