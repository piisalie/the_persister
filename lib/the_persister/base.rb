module ThePersister
  class Base

    def self.table_name(name = nil)
      @table_name ||= name
    end

    def self.attributes(*attributes)
      @attributes ||= begin
        attributes << :id
        attributes.each do |attr|
          attr_accessor attr
        end
        attributes
      end
    end

    def initialize( atts = self.class.attributes.merge({id: nil}) )
      atts.each do |att, value|
        public_send("#{att}=", value)
      end
    end

    def to_hash
      atts = Hash.new
      self.class.attributes.each do |att|
        atts[att] = public_send(att) if public_send(att)
      end
      atts
    end

  end
end
