# Built-in helpers for the DSL form
class Lono::Template::Strategy::Dsl::Builder
  module Helpers
    extend Memoist
    include CoreHelper
    include FileHelper
    include ParamHelper
    include S3Helper
    include TagsHelper
  end
end