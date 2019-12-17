require 'fileutils'
require 'yaml'

class Lono::Upgrade
  class Upgrade42 < Lono::Sequence
    def upsert_gitignore
      text =<<-EOL
.lono/current
EOL
      if File.exist?(".gitignore")
        append_to_file ".gitignore", text
      else
        create_file ".gitignore", text
      end
    end

    def update_settings_yaml
      path = "config/settings.yml"
      puts "Updating #{path}."
      data = YAML.load_file(path)
      text = YAML.dump(data)
      IO.write(path, text)
    end
  end
end
