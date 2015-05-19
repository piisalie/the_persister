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
      object_class.new(@db[object_class.table_name][id])
    end

    private

    def insert(object)
      @db[object.class.table_name] << object.attributes
      object.id = @db[object.class.table_name].count - 1
    end

    def update(object)
      @db[object.class.table_name][object.id] = remove_id(object.attributes)
    end

    def remove_id(attributes)
      attributes.delete_if { |k,_| k == :id }
      attributes
    end

  end
end
