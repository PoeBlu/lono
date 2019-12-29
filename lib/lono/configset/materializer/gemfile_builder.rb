require 'open3'

module Lono::Configset::Materializer
  class GemfileBuilder
    extend Memoist

    def initialize(*jades)
      @jades = jades.flatten
      @build_root = "#{Lono.root}/tmp/configsets"
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
        args = source.args(jade)
        args = args.map { |s| %Q|"#{s}"| }.join(', ')
        options = source.options(jade)
        options = options.inject([]) { |r,(k,v)| r << %Q|#{k}: "#{v}"| }.join(', ')
        line = %Q|gem #{args}, #{options}|
        lines << line unless lines.include?(line)
      end
      lines.sort!
      lines.unshift('source "https://rubygems.org"')
      lines.join("\n") + "\n"
    end

    def local_exist?(jade)
      !!jade.finder.find(jade.name, local_only: true)
    end

    def write(gemfile)
      path = "#{@build_root}/Gemfile"
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, gemfile)
    end

    def bundle
      Bundler.with_original_env do
        bundle_install
      end
    end

    def source
      Source.new
    end
    memoize :source

    def bundle_install
      command = "cd #{@build_root} && bundle install"
      puts "=> #{command}" if ENV['LONO_DEBUG']
      stdout, stderr, status = Open3.capture3(command)

      puts stdout if ENV['LONO_DEBUG']
      unless status.success?
        names = @jades.map(&:name)
        gem_text = names.size == 1 ? "gem" : "gems"
        puts "Fail to materialize #{gem_text} #{names.join(', ')}".color(:red)
        puts "Failed running => #{command}"
        puts stderr
        if stderr.include?("correct access rights")
          puts "Are you sure you have access to the git repo?".color(:yellow)
        end
        exit 1
      end
    end

    def clean_gemfile
      FileUtils.rm_f("#{@build_root}/Gemfile")
      FileUtils.rm_f("#{@build_root}/Gemfile.lock")
    end
  end
end
