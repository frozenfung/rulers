require "sqlite3"
require "rulers/util"

DB=SQLite3::Database.new "test.db"

module Rulers
  module Model
    class SQLite
      def initialize(data = nil)
        @hash = data
      end

      def self.table
        Rulers.to_underscore name
      end

      def save!
        unless @hash["id"]
          self.class.create
          return true
        end

        fields = @hash.map { |k, _| k }.join ","
        values = @hash.map { |_, v| "\"#{v.to_s}\"" }.join ","

        # sql = "UPDATE #{self.class.table} SET #{fields} WHERE id = #{@hash["id"]}"
       # DB.execute(sql)
      #
        # puts fields
        # puts values
        #
        DB.execute <<SQL
UPDATE #{self.class.table}
SET (#{fields}) = (#{values})
WHERE id = #{@hash["id"]}
SQL

        true
      end

      def save
        self.save! rescue false
      end

      # schema
      def self.schema
        return @schema if @schema
        @schema = {}

        DB.table_info(table) do |row|
          @schema[row["name"]] = row["type"]
        end

        @schema
      end

      # schema.keys.each do |key|
      #   define_method(key) do
      #     @hash[key.to_s]
      #   end
      # end

      def self.to_sql(val)
        case val
        when Numeric
          val.to_s
        when String
          "#{val}"
        else
          raise "Can't change #{val.class} to SQL!"
        end
      end

      def self.find(id)
        row = DB.execute <<SQL
select #{schema.keys.join ","} from #{table}
where id = #{id};
SQL
        data = Hash[schema.keys.zip row[0]]
        self.new data
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      # create
      def self.create(values)
        values.delete "id"
        keys = schema.keys - ["id"]
        vals = keys.map do |key|
          values[key] ? to_sql(values[key]) : "null"
        end


        sql = "INSERT INTO #{table} (#{keys.join ", "}) VALUES (?,?,?)"
        DB.execute(sql, vals)

        data = Hash[keys.zip vals]
        sql = "SELECT last_insert_rowid();"
        data["id"] = DB.execute(sql)[0][0]
        self.new data
      end

      def self.count
        DB.execute(<<SQL)[0][0]
          SELECT COUNT(*) FROM #{table}
SQL
      end
    end
  end
end
