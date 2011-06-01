class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :industry
  field :city  
  field :queries, type: Array
  field :favorite_vacancies, type: Array, default: []
  
  def favorite_vacancy_objects
    Vacancy.find(favorite_vacancies)
  end
end
