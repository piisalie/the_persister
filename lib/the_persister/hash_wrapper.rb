require_relative 'errors'

module ThePersister
  class HashWrapper

    attr_reader :db

    def initialize
      @db = Hash.new { |h, k| h[k] = [ :this_space_left_intentionally_blank ] }
    end

    def save(object)
      object.id ? update(object) : insert(object)
    end

    def find(object_class, id)
      raise CouldNotFindRecordError, "Could not find #{object_class} with id: #{id}" unless @db[object_class.table_name][id]
      object_class.new(@db[object_class.table_name][id].merge(id: id))
    end

    def destroy(object)
      old_record = @db[object.class.table_name].delete_at(object.id)
      old_record.each { |att, val| object.public_send(att.to_s + "=", val) }
      object
    end

    private

    def insert(object)
      @db[object.class.table_name] << object.to_hash
      object.id = @db[object.class.table_name].count - 1
      object
    end

    def update(object)
      @db[object.class.table_name][object.id] = remove_id(object.to_hash)
    end

    def remove_id(attributes)
      attributes.delete_if { |k,_| k == :id }
      attributes
    end

  end
end
