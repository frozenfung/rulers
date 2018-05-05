require "sqlite3"
require "rulers/util"

DB=SQLite3::Database.new "test.db"

module Rulers
  module Model
    class SQLite
      def self.table
        Rulers.to_underscore name
      end

      def self.schema
        return @schema if @schema
        @schema = {}

        DB.table_info(table) do |row|
          @schema[row["name"]] = row["type"]
        end

        @schema
      end
    end
  end
end
