module Lono
  class Generate < AbstractBase
    # Use class variable to cache this only runs once across all classes. base.rb, diff.rb, preview.rb
    @@generated = nil
    def all
      return @@generated if @@generated

      if @options[:lono]
        ensure_s3_bucket_exist

        build_scripts
        generate_templates # generates with some placeholders for build_files IE: file://app/files/my.rb
        build_files # builds app/files to output/BLUEPRINT/files

        post_process_templates

        unless @options[:noop]
          upload_files
          upload_scripts
          upload_templates
        end
      end

      # Pass down all options to generate_params because it eventually uses template
      param_generator.generate  # Writes the json file in CamelCase keys format
      @@generated = param_generator.params    # Returns Array in underscore keys format

      check_for_errors
      @@generated
    end

    def param_generator
      o = {
        regenerate: true,
        allow_not_exists: true,
      }.merge(@options)
      Lono::Param::Generator.new(o)
    end
    memoize :param_generator

    def ensure_s3_bucket_exist
      bucket = Lono::S3::Bucket.new
      return if bucket.exist?
      bucket.deploy
    end

    def build_scripts
      Lono::Script::Build.new(@options).run
    end

    def build_files
      Lono::AppFile::Build.new(@options).run
    end

    def generate_templates
      Lono::Template::Generator.new(@options).run
    end

    def post_process_templates
      Lono::Template::PostProcessor.new(@options).run
    end

    def upload_templates
      Lono::Template::Upload.new(@options).run
    end

    def upload_scripts
      Lono::Script::Upload.new(@options).run
    end

    def upload_files
      Lono::AppFile::Upload.new(@options).upload
    end

    def check_for_errors
      errors = check_files
      unless errors.empty?
        puts "Please double check the command you ran.  There were some errors."
        puts "ERROR: #{errors.join("\n")}".color(:red)
        exit
      end
    end

    def check_files
      errors = []
      unless File.exist?(template_path)
        errors << "Template file missing: could not find #{template_path}"
      end
      errors
    end
  end
end
