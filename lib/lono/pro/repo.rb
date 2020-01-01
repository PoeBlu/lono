class Lono::Pro
  class Repo < Base
    def run
      data = api.repos(@options[:type])
      header = ["Name", "Docs Repo", "Description"]
      rows = data.map do |d|
        [d[:name], d[:docs_url], d[:description]]
      end
      show_table(header, rows)
    end
  end
end
