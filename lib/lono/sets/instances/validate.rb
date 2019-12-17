class Lono::Sets::Instances
  module Validate
    def validate!
      invalid = regions.blank? || accounts.blank?
      if invalid
        puts "ERROR: You must provide accounts and regions.".color(:red)
        exit 1
      end
    end
  end
end
