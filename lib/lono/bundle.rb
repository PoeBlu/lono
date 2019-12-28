module Lono
  # Named Bundle vs Bundler to avoid having to fully qualify ::Bundler
  module Bundle
    # Looks like for zeitwerk module autovivification to work `bundle exec` must be called.
    # This allows zeitwork module autovivification to work even if the user has not called lono with `bundle exec lono`.
    # Bundler.setup is essentially the same as `bundle exec`
    # Reference: https://www.justinweiss.com/articles/what-are-the-differences-between-irb/
    #
    # The Bundler.setup is only necessary because we use Bundler.require after require "zeitwerk" is called.
    #
    # Note, this is called super early right before require "zeitwerk"
    # The initially Bundler.setup does not include the Lono.env group.
    # Later in Lono::Booter, Bundle.require is called and includes the Lono.env group.
    #
    def setup
      return unless gemfile?
      Kernel.require "bundler/setup"
      Bundler.setup # Same as Bundler.setup(:default)
    rescue LoadError => e
      handle_error(e)
    end

    # Bundler.require called early in lono.rb.  This will eagerly require all gems in the
    # Gemfile. This means the user will not have to explictly require dependencies.
    def require
      return unless gemfile?
      Kernel.require "bundler/setup"
      Bundler.require(*bundler_groups)
    rescue LoadError => e
      handle_error(e)
    end

    def handle_error(e)
      puts e.message
      puts <<~EOL.color(:yellow)
        WARNING: Unable to require "bundler/setup"
        There may be something funny with your ruby and bundler setup.
        You can try upgrading bundler and rubygems:

            gem update --system
            gem install bundler

        Here are some links that may be helpful:

        * https://bundler.io/blog/2019/01/03/announcing-bundler-2.html

        Also, running bundle exec in front of your command may remove this message.
      EOL
    end

    def gemfile?
      ENV['BUNDLE_GEMFILE'] || File.exist?("Gemfile")
    end

    def bundler_groups
      [:default, Lono.env.to_sym]
    end

    extend self
  end
end
