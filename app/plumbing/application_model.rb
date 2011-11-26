class ApplicationModel
  module ClassMethods
    def get(id)
      find(id)
    end    
  end
  
  def self.inherited(derived)
    derived.class_eval do
      include Mongoid::Document
      include Mongoid::Timestamps
      include MongoidExt::Pagination
      extend ClassMethods
    end
  end
end
