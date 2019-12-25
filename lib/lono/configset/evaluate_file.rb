class Lono::Configset
  module EvaluateFile
    def evaluate_file(path)
      return unless File.exist?(path)
      instance_eval(IO.read(path), path)
    end
  end
end
