class ActiveRecord::Base
  named_scope :where,    lambda { |arg| { :conditions => arg } }
  named_scope :order_by, lambda { |*args| { :order => args.join(', ') } }
  named_scope :select,   lambda { |*args| { :select => args.join(', ') } }

  alias new? new_record?
end