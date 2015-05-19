require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/mock'

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
