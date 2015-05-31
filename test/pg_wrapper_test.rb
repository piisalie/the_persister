require_relative 'test_helper'
require_relative '../lib/the_persister/pg_wrapper'

module ThePersister
  describe 'PGWrapper' do

    def build_pg_wrapper(opts)
      PGWrapper.new(opts)
    end

    describe 'saving' do
      def mock_save_request(test_object)
        test_db     = Minitest::Mock.new
        test_db.expect(:exec, [{"id" => 2}]) do |arg1, arg2|
          arg1 == "INSERT INTO #{test_object.class.table_name} (name, age) VALUES ($1, $2) RETURNING id;" &&
            arg2 == test_object.to_hash.values
        end
        test_db
      end

      it 'can generate the correct save query' do
        test_object = ExampleObj.new( name: 'Frank', age: 20 )
        test_db     = mock_save_request(test_object)

        persister = build_pg_wrapper( { db_connection: test_db } )
        id        = persister.save(test_object)

        assert test_db.verify
      end

      it 'assigns the in memory object an id' do
        test_object = ExampleObj.new( name: 'Frank', age: 20 )
        test_db     = mock_save_request(test_object)

        persister = build_pg_wrapper( { db_connection: test_db } )

        test_object.id.must_equal(nil)
        persister.save(test_object)
        test_object.id.must_equal(2)
      end
    end

    describe 'loading' do
      def mock_load_request(test_object_class, obj_atts, response=[ obj_atts ] )
        test_db  = Minitest::Mock.new
        columns  = test_object_class.attributes.map { |a| "\"#{a.to_s}\""}.join(", ")

        test_db.expect(:exec, response) do |arg1, arg2|
          arg1 == "SELECT #{columns} FROM #{test_object_class.table_name} WHERE id = $1 LIMIT 1;" &&
            arg2 == [ obj_atts[:id] ]
        end
        test_db
      end

      it 'can generate the correct find/load query' do
        test_object_class = ExampleObj
        obj_atts          = { 'age' => 32, 'name' => 'Frank', 'id' => 2 }
        test_db           = mock_load_request(test_object_class, obj_atts)
        persister         = build_pg_wrapper( { db_connection: test_db } )

        persister.find(test_object_class, obj_atts[:id])
        test_db.verify
      end

      it 'returns a hydrated object' do
        test_object_class = ExampleObj
        obj_atts          = { 'age' => 32, 'name' => 'Frank', 'id' => 2 }
        test_db           = mock_load_request(test_object_class, obj_atts)
        persister         = build_pg_wrapper( { db_connection: test_db } )

        result = persister.find(test_object_class, obj_atts[:id])
        assert_equal test_object_class, result.class
        assert_equal obj_atts['age'],   result.age
        assert_equal obj_atts['name'],  result.name
        assert_equal obj_atts['id'],    result.id
      end

      it 'raises a helpful error if the record cannot be found' do
        test_object_class = ExampleObj
        obj_atts          = { 'age' => 32, 'name' => 'Frank', 'id' => 2 }
        test_db           = mock_load_request(test_object_class, obj_atts, [ ])
        persister         = build_pg_wrapper( { db_connection: test_db } )

        assert_raises(CouldNotFindRecordError) { persister.find(test_object_class, obj_atts[:id]) }
      end
    end

    describe 'destruction!' do

      def mock_destroy_request(obj)
        test_db  = Minitest::Mock.new

        test_db.expect(:exec, []) do |arg1, arg2|
          arg1 == "DELETE FROM #{obj.class.table_name} WHERE id = $1;" &&
            arg2 == [ obj.id ]
        end
        test_db
      end

      it 'it generates the correct destroy query' do
        test_object = ExampleObj.new( name: 'Frank', age: 20 )
        test_db     = mock_destroy_request(test_object)
        persister   = build_pg_wrapper( { db_connection: test_db } )

        persister.destroy(test_object)
        test_db.verify
      end

      it 'it returns the object that was destroyed' do
        test_object = ExampleObj.new( name: 'Frank', age: 20 )
        test_db     = mock_destroy_request(test_object)
        persister   = build_pg_wrapper( { db_connection: test_db } )

        result = persister.destroy(test_object)
        assert_equal result, test_object
      end
    end

  end
end
