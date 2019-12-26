require "bundler"

module Lono::Blueprint::Configset
  class Downloader
    extend Memoist

    def initialize(options={})
      @options = options
      @blueprint = options[:blueprint]
      @configsets = options[:configsets] || Lono::Configset::Register::Blueprint.configsets
    end

    def run
      return if @configsets.empty?
      puts "Downloading configsets for blueprint #{@blueprint}"
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
      return if lines.empty?
      lines.join("\n") + "\n"
    end

    def local_configset?(name)
      finder = Lono::Finder::Blueprint::Configset.new(@options)
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

    def source
      Source.new
    end
    memoize :source

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
      FileUtils.rm_f("tmp/configsets/Gemfile.lock")
    end
  end
end
