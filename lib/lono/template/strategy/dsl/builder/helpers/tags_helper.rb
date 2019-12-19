module Lono::Template::Strategy::Dsl::Builder::Helpers
  module TagsHelper
    def tags(list={})
      casing = list.delete(:casing) || :camelize
      if list.empty?
        tag_list(@tags) if @tags # when list is empty, use @tags variable. If not set then return nil
      else
        tag_list(list, casing: casing)
      end
    end

    def tag_list(list, casing: :camelize)
      raise "tags list cannot be empty" if list == nil

      if list.is_a?(Array)
        hash = list.inject({}) do |h,i|
          i.symbolize_keys!
          h[i[:Key]] = i[:Value]
          h
        end
        return tag_list(hash) # recursive call tag_list to normalized the argument with a Hash
      end

      list.map do |k,v|
        k = k.to_s
        k = case casing
        when :camelize
          k.camelize
        when :underscore
          k.underscore
        when :dasherize
          k.dasherize
        else # leave alone
          k
        end

        {Key: k, Value: v}
      end
    end

    def dimensions(hash, casing: :camelize)
      tag_list(hash, casing: casing).map { |h|
        h[:Name] = h.delete(:Key) || h.delete(:key)
        h
      }
    end
  end
end
