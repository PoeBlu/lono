class Lono::Configset
  class Materializer < Lono::AbstractBase
    extend Memoist

    def initialize(options={})
      super
      @registry = options[:registry]
      @finder_class = @registry[:finder_class]
    end

    def materialize
      clean_gemfile
      gemfile = build_gemfile
      return unless gemfile
      write(gemfile)
      bundle
      load_config
    end

    def load_config
      "#{Lono.root}/tmp/materializer/.meta/config.yml"

    end

    def build_gemfile
      return if local_configset?(@registry[:name])
      options = source.options(@registry) # TODO: handle other Gemfile options
      args = options.inject([]) { |r,(k,v)| r << %Q|#{k}: "#{v}"| }.join(', ')
      %Q|gem "#{@registry[:name]}", #{args}\n|
    end

    def local_configset?(name)
      finder = @finder_class.new(@options)
      !!finder.find_local(name)
    end

    def write(gemfile)
      path = "#{Lono.root}/tmp/materializer/Gemfile"
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, gemfile)
    end

    def bundle
      puts "Materializing configset #{@registry[:depends_on]}".color(:purple)
      Dir.chdir("tmp/materializer/") do
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
      FileUtils.rm_f("tmp/materializer/Gemfile")
      FileUtils.rm_f("tmp/materializer/Gemfile.lock")
    end
  end
end
