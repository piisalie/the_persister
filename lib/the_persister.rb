require 'pg'
require_relative 'the_persister/hash_wrapper'
require_relative 'the_persister/pg_wrapper'

module ThePersister

  def self.pg_database(name:)
    db = PG.connect(dbname: name)
    PGWrapper.new(db_connection: db)
  end

  def self.hash_database
    HashWrapper.new
  end

end
