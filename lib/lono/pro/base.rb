require "text-table"

class Lono::Pro
  class Base
    extend Memoist

    def initialize(options={})
      @options = options
    end

    def api
      Lono::Api::Client.new
    end
    memoize :api

    def show_table(header, data)
      table = Text::Table.new
      table.head = header
      data.each do |item|
        table.rows << item
      end
      puts table
      puts "Total #{table.rows.size}"
    end
  end
end
