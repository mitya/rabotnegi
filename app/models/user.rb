class User < ApplicationModel
  field :industry
  field :city  
  field :browser
  field :ip_address
  field :queries, type: Array
  field :favorite_vacancies, type: Array, default: []
  
  def favorite_vacancy_objects
    Vacancy.find(favorite_vacancies)
  end
  
  def self.demo
    Rails.logger.debug "User.demo() at #{Time.now}"
    MongoLog.write(nil, :info, 'user.demo')
  end
end
