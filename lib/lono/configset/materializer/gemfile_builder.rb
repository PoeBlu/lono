module Lono::Configset::Materializer
  class GemfileBuilder
    extend Memoist

    def initialize(*jades)
      @jades = jades.flatten
    end

    def build
      puts "Materializing #{@jades.map(&:name)}"
      clean_gemfile
      gemfile = create_gemfile(@jades)
      return unless gemfile
      write(gemfile)
      bundle
    end

    def create_gemfile(jades)
      return if jades.empty?

      lines = []
      jades.each do |jade|
        return if local_exist?(jade)
        options = source.options(jade)
        args = options.inject([]) { |r,(k,v)| r << %Q|#{k}: "#{v}"| }.join(', ')
        line = %Q|gem "#{jade.name}", #{args}|
        lines << line unless lines.include?(line)
      end
      lines.sort.join("\n") + "\n"
    end

    def local_exist?(jade)
      !!jade.finder.find_local(jade.name)
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
