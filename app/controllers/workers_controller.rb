class WorkersController < ApplicationController
  def login_page
    template :login
  end

  def login
    @resume = Resume.authenticate(params[:name], params[:password])
    session[:resume_id] = @resume.id
    cookies[:resume_id] = { :value => @resume.id.to_s, :expires => 14.days.from_now, :path => '/' } if params[:remember_me] == 'on'
    redirect my_resumes_path
  rescue ArgumentError => e
    flash[:error] = e.message
    template :login
  end

  def logout
    reset_session
    cookies.delete(:resume_id)
    redirect :login
  end
end
