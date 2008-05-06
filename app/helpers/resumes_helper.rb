module ResumesHelper
	def resumes_page_title
		city = $city_map[params[:city].to_sym] if params[:city]
		industry = $industry_map[params[:industry].to_sym] if params[:industry]
		query = params[:q]
		page = params[:p]
		
		title = "Резюме: #{city}"
		title << " — #{industry}" if industry
		title << " — #{query}" if query
		title << ", стр. №#{page}" if page
		return title
	end
end