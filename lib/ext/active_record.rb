class ActiveRecord::Base
  alias new? new_record?
end

class << ActiveRecord::Base
  def property(*args)
  end
end
