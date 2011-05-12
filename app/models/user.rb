class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :industry
  field :city  
  field :queries, type: Array
end
