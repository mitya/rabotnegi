class SiteController < ApplicationController
  def map
    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  def load_data_from_rabota_ru
    loader = Rabotaru::Loader.new
    loader.load
    render text: 'ok'
  end
  
  def ssl
    render text: request.ssl? ? 'SSL' : 'not SSL'
  end
  
  def locale
    render text: I18n.locale
  end
  
  def reset
    reset_session
    redirect_to root_path
  end

  def environment
    render :text => Rails.env
  end
  
  def info
    render json: {
      env: Rails.env,
      db: Vacancy.db.name,
      counts: {
        vacancies: Vacancy.count,
        events: MongoLog::Item.count,
        users: User.count
      } 
    }
  end
  
  def starter
    render text: $0
  end
  
  def error
    raise ArgumentError, "You requested an error!"
  end  
end
