module ThePersister
  class PGWrapper

    attr_reader :db

    def initialize(db_connection:)
      @db = db_connection
    end

    def save(object)
      atts = object.attributes.keys
      resulting_id = db.exec("INSERT INTO #{object.class.table_name} (#{atts.join(', ')}) VALUES (#{positions(atts)}) RETURNING id;",
        object.attributes.values
      )
      object.id = resulting_id
      object
    end

    def find(object_class, id)
      atts = db.exec("SELECT #{columns(object_class)} FROM #{object_class.table_name} WHERE id = $1 LIMIT 1;", [ id ])[0]
      object_class.new(atts)
    end

    private

    def columns(object_class)
      object_class.attributes.map { |a| "\"#{a.to_s}\""}.join(', ')
    end

    def positions(atts)
      Array.new(atts.size) { |i| i + 1 }.map { |n| "$#{n}"}.join(', ')
    end
  end

end