require_relative 'errors'

module ThePersister
  class PGWrapper

    attr_reader :db

    def initialize(db_connection:)
      @db = db_connection
    end

    def save(object)
      atts = object.to_hash.keys
      resulting = db.exec("INSERT INTO #{object.class.table_name} (#{atts.join(', ')}) VALUES (#{positions(atts)}) RETURNING id;",
        object.to_hash.values
      )
      object.id = resulting[0]['id']
      object
    end

    def find(object_class, id)
      atts = db.exec("SELECT #{columns(object_class)} FROM #{object_class.table_name} WHERE id = $1 LIMIT 1;", [ id ]).first
      raise CouldNotFindRecordError, "Could not find #{object_class} with id: #{id}" unless atts

      object_class.new(symbolize_keys(atts))
    end

    def destroy(object)
      db.exec("DELETE FROM #{object.class.table_name} WHERE id = $1;", [ object.id ])
      object
    end

    private

    def columns(object_class)
      object_class.attributes.map { |a| "\"#{a.to_s}\""}.join(', ')
    end

    def positions(atts)
      Array.new(atts.size) { |i| i + 1 }.map { |n| "$#{n}"}.join(', ')
    end

    def symbolize_keys(atts)
      Hash[ atts.map{ |k, v| [ k.to_sym, v ] } ]
    end
  end

end
