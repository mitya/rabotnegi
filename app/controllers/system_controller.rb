class SystemController < ApplicationController
  def load_data_from_rabota_ru
    loader = RabotaRu::VacancyLoader.new
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
  
  def error
    raise ArgumentError, "You requested an error!"
  end
  
  def starter
    render text: $0
  end
  
  def test
    render "site/test", layout: false
  end
  
  def lorem
    @count = params[:count].to_i
    render "test/lorem", layout: false
  end
end
