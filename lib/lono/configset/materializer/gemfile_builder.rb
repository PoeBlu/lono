require 'open3'

module Lono::Configset::Materializer
  class GemfileBuilder
    extend Memoist

    def initialize(*jades)
      @jades = jades.flatten
    end

    def build
      puts "GemfileBuilder#build materializing #{@jades.map(&:name)}" if ENV['LONO_DEBUG']
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
      !!jade.finder.find(jade.name, local_only: true)
    end

    def write(gemfile)
      path = "tmp/configsets/Gemfile"
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, gemfile)
    end

    def bundle
      Dir.chdir("tmp/configsets/") do
        Bundler.with_clean_env do
          bundle_install
        end
      end
    end

    def source
      Source.new
    end
    memoize :source

    def bundle_install
      command = "bundle install"
      puts "=> #{command}" if ENV['LONO_DEBUG']
      stdout, stderr, status = Open3.capture3(command)
      puts stdout if ENV['LONO_DEBUG']
      unless status.success?
        puts "Fail to materialize gems #{@jades.map(&:name).join(', ')}".color(:red)
        puts "Failed running => #{command}"
        puts stderr
        if stderr.include?("correct access rights")
          puts "Are you sure you have access to the git repo?".color(:yellow)
        end
        exit 1
      end
    end

    def clean_gemfile
      FileUtils.rm_f("tmp/configsets/Gemfile")
      FileUtils.rm_f("tmp/configsets/Gemfile.lock")
    end
  end
end
