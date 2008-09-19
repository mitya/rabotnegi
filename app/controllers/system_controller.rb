class SystemController < ApplicationController
	def load_data_from_rabota_ru
		loader = RabotaRu::VacancyLoader.new
		loader.load
		render :text => 'ok'
	end
	
	def ssl
	  render :text => request.ssl? ? 'SSL' : 'not SSL'
	end
	
	def reset
	 reset_session
	 redirect root_path
	end
end
