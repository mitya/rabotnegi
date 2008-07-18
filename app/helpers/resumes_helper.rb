module ResumesHelper
	def resumes_page_title
		city = City[params[:city]] if params[:city]
		industry = Industry[params[:industry]] if params[:industry]
		query = params[:q]
		page = params[:p]
		
		title = "Резюме: #{city}"
		title << " — #{industry}" if industry
		title << " — #{query}" if query
		title << ", стр. №#{page}" if page
		title
	end
end