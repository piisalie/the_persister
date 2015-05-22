require_relative 'test_helper'
require_relative '../lib/the_persister/hash_wrapper'

module ThePersister
  describe 'HashWrapper' do

    def build_hasher
      HashWrapper.new
    end

    it 'has a method for accessing the underlying hash' do
      hash_db = build_hasher
      assert_equal({ }, hash_db.db)
    end

    describe 'save' do
      it 'saves an object into the hash' do
        test_obj = ExampleObj.new( name: "Charlie", age: 35 )
        hash_db  = build_hasher

        hash_db.save(test_obj)
        assert_equal(
          [ :this_space_left_intentionally_blank, { name: "Charlie", age: 35 } ],
          hash_db.db.fetch(test_obj.class.table_name)
        )
      end

      it 'assigns the object an id' do
        test_obj = ExampleObj.new( name: "Charlie", age: 35 )
        hash_db  = build_hasher

        result = hash_db.save(test_obj)

        assert_equal 1, result.id
      end

      it 'updates existing records' do
        test_obj = ExampleObj.new( name: "Charlie", age: 35, id: 3 )
        hash_db  = build_hasher
        hash_db.save(test_obj)

        test_obj.age = 36
        hash_db.save(test_obj)

        assert_equal(
          { name: "Charlie", age: 36 },
          hash_db.db.fetch(test_obj.class.table_name)[test_obj.id]
        )
        assert_equal 3, test_obj.attributes.fetch(:id)
      end
    end

    describe 'find' do
      it 'returns a hydrated object' do
        test_object_class = ExampleObj
        obj_atts          = { name: "Charlie", age: 35}
        hash_db           = build_hasher
        obj               = test_object_class.new(obj_atts)
        hash_db.save(obj)

        record = hash_db.find(test_object_class, obj.id)

        assert_equal obj_atts[:name], record.name
        assert_equal obj_atts[:age],  record.age
        assert_equal obj.id,          record.id
      end
    end

  end
end
