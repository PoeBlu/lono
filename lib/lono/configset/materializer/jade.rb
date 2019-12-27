require "bundler"

module Lono::Configset::Materializer
  class Jade
    extend Memoist

    def initialize(jade)
      @jade = jade
    end

    def install
      puts "Materializing #{@jade.name}"
      clean_gemfile
      gemfile = build_gemfile
      return unless gemfile
      write(gemfile)
      bundle
    end

    def build_gemfile
      return if local_configset?(@jade.name)
      options = source.options(@jade)
      args = options.inject([]) { |r,(k,v)| r << %Q|#{k}: "#{v}"| }.join(', ')
      %Q|gem "#{@jade.name}", #{args}\n|
    end

    def local_configset?(name)
      !!@jade.finder.find_local(name)
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
