module Lono::Template::Strategy
  class Url < Base
    def run
      Lono::Cfn::Download.new(@options).run
    end
  end
end
