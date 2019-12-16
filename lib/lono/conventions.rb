module Lono
  module Conventions
    def naming_conventions(options)
      o = options.deep_symbolize_keys
      stack = o[:stack]
      blueprint = o[:blueprint] || o[:stack]
      template = o[:template] || o[:blueprint]
      param = o[:param] || template || o[:blueprint]
      [stack, blueprint, template, param]
    end

    def template_path
      "#{Lono.config.output_path}/#{@blueprint}/templates/#{@template}.yml"
    end
  end
end
