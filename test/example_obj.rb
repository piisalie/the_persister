require_relative '../lib/the_persister/base'

class ExampleObj < ThePersister::Base
  table_name 'test_obj'
  attributes :name, :age
end
