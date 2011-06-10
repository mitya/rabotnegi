class ApplicationModel
  def inherited(subclass)
    class << subclass
      include Mongoid::Document
      
    end
  end  
end
