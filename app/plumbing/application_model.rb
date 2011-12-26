class ApplicationModel
  def self.inherited(derived)
    derived.class_eval do
      include Mongoid::Document
      include Mongoid::Timestamps
      include MongoidExt::Pagination
    end
  end
end
