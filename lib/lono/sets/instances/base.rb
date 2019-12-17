class Lono::Sets::Instances
  class Base < Lono::Sets::Base
    # Simple structure to help with subtracting logic
    # [["112233445566", "us-west-1"], ["112233445566", "us-west-1"]]
    def requested
      requested = []
      accounts.each do |a|
        regions.each do |r|
          item = [a,r]
          requested << item
        end
      end
      requested.sort.uniq
    end
    memoize :requested

    def accounts
      @options[:accounts]
    end

    def regions
      @options[:regions]
    end
  end
end
