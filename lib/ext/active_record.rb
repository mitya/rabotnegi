class ActiveRecord::Base
  named_scope :where, lambda { |*args| { :conditions => args.flatten.reduce } }

  alias new? new_record?  
  
  def save_with_captcha!
    save_with_captcha || raise(ActiveRecord::RecordInvalid)
  end
end

class << ActiveRecord::Base
  def property(*args)    
  end  
end