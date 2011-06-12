class MongoModel
  def self.inherited(klass)
    klass.class_eval do
      include Mongoid::Document
    end
  end  
end
