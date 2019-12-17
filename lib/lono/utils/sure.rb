module Lono::Utils
  module Sure
    def sure?(message, desc=nil)
      if @options[:sure]
        sure = 'y'
      else
        puts "#{message} (y/N)"
        puts desc if desc
        sure = $stdin.gets
      end

      unless sure =~ /^y/
        puts "Whew! Exiting."
        exit 0
      end
    end
  end
end
