class WorkersController < ApplicationController
  def login_page
    render :login
  end

  def login
    @resume = Resume.authenticate(params[:name], params[:password])
    session[:resume_id] = @resume.id
    cookies[:resume_id] = { :value => @resume.id.to_s, :expires => 14.days.from_now, :path => '/' } if params[:remember_me] == 'on'
    redirect_to my_resume_path
  rescue ArgumentError => e
    flash[:error] = e.message
    render :login
  end

  def logout
    reset_session
    cookies.delete(:resume_id)
    redirect_to workers_login_path
  end
end
