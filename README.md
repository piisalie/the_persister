The Persister
=============

## Description
A layer for communicating with the database and providing saving, finding, and
destroying objects.

It supports either a hash or a pg backend. It's tiny, and it doesn't do much,
and considers that a feature.

Things it does not to:
* create your database
* manage your migrations
* manage or create database tables
* care about cross-model relationships

## Usage

### Models
Persister models are pretty simple. A model only needs to inherit from `ThePersister::Base`
and define `attributes` and `table_name`. Attributes should be a comma separated list of
symbols that coincide with column names, and the table_name should match the table in
the database you wish the model to be correlated with. An example model can be found in
`test/example_obj.rb`

### Postgres connector
To create a pg database connection:
```ruby
persister = ThePersister.pg_database(name: "database_name")
```

The persister object will respond to `save(some_obj)`, `find(some_obj_class, id)`,
and `destroy(some_obj)` provided that `some_obj` is a properly setup model. The Persister
also provides access to the underlying pg backend by using `persister.db`

### Hash database synthesizer
To create a hash based database:
```ruby
persister = ThePersister.hash_database
```

A Persister with a hash backend will respond to the same messages as the Postgres
variant in (hopefully) the same ways. It also requires properly setup models.


## NOTE: This project is still a work in progress
todo before release:
- [ ] refactor tests for less less duplication
- [ ] fix pg_wrapper save so it can update an existing record
- [x] add destroy
- [x] add a gemspec
- [x] clean up the example object, and be more clear about the requirements for persistence
- [x] finish the readme
