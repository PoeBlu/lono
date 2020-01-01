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

  private
    def show_table(header, data)
      table = Text::Table.new
      table.head = header
      data.each do |item|
        table.rows << item
      end
      puts table
      # puts "Total #{table.rows.size}"
    end
  end
end
