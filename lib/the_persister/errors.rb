module ThePersister
  ThePersisterError       = Class.new(StandardError)
  CouldNotFindRecordError = Class.new(ThePersisterError)
end
