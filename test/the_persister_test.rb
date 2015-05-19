require_relative 'test_helper'
require_relative '../lib/the_persister'

describe 'ThePersister' do

  class ExampleObj
    def self.table_name
      'test_obj'
    end

    def self.attributes
      [ :name, :age, :id ]
    end

    attr_accessor :name, :age, :id

    def initialize(name:, age:, id: nil)
      @name = name
      @age  = age
      @id   = id
    end

    def attributes
      atts = Hash.new
      self.class.attributes.each do |att|
        atts[att] = public_send(att) if public_send(att)
      end
      atts
    end
  end

  def build_persister(opts)
    ThePersister.new(opts)
  end

  describe 'saving' do
    def mock_save_request(test_object)
      test_db     = Minitest::Mock.new
      test_db.expect(:exec, 2) do |arg1, arg2|
        arg1 == "INSERT INTO #{test_object.class.table_name} (name, age) VALUES ($1, $2) RETURNING id;" &&
          arg2 == test_object.attributes.values
      end
      test_db
    end

    it 'can generate the correct save query' do
      test_object = ExampleObj.new( name: 'Frank', age: 20 )
      test_db     = mock_save_request(test_object)

      persister = build_persister( { db_connection: test_db } )
      id        = persister.save(test_object)

      assert test_db.verify
    end

    it 'assigns the in memory object an id' do
      test_object = ExampleObj.new( name: 'Frank', age: 20 )
      test_db     = mock_save_request(test_object)

      persister = build_persister( { db_connection: test_db } )

      test_object.id.must_equal(nil)
      persister.save(test_object)
      test_object.id.must_equal(2)
    end
  end

  describe 'loading' do
    def mock_load_request(test_object_class, obj_atts)
      test_db  = Minitest::Mock.new
      columns  = test_object_class.attributes.map { |a| "\"#{a.to_s}\""}.join(", ")

      test_db.expect(:exec, [obj_atts]) do |arg1, arg2|
        arg1 == "SELECT #{columns} FROM #{test_object_class.table_name} WHERE id = $1 LIMIT 1;" &&
          arg2 == [ obj_atts[:id] ]
      end
      test_db
    end

    it 'can generate the correct find/load query' do
      test_object_class = ExampleObj
      obj_atts          = { age: 32, name: 'Frank', id: 2 }
      test_db           = mock_load_request(test_object_class, obj_atts)
      persister         = build_persister( { db_connection: test_db } )

      persister.find(test_object_class, obj_atts[:id])
      test_db.verify
    end

    it 'returns a hydrated object' do
      test_object_class = ExampleObj
      obj_atts          = { age: 32, name: 'Frank', id: 2 }
      test_db           = mock_load_request(test_object_class, obj_atts)
      persister         = build_persister( { db_connection: test_db } )

      result = persister.find(test_object_class, obj_atts[:id])
      assert_equal test_object_class,  result.class
      assert_equal obj_atts[:age],     result.age
      assert_equal obj_atts[:name],    result.name
      assert_equal obj_atts[:id],      result.id
    end
  end

end
