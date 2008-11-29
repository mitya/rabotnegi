class ResumesController < ApplicationController
  before_filter :try_login_from_cookie
  verify :only => [:edit, :update, :destroy, :my], :session => :resume_id, :redirect_to => { :action => :login }
  ssl_required :login, :log_in
  
  def index
    @resumes = Resume.
      search(params.slice(:city, :industry, :keywords, :salary)).
      scoped(:order => 'min_salary', :select => 'id, job_title, min_salary') if params[:city]
  end

  def show
    @resume = Resume.find(params[:id])
  end
  
  def my
    @resume = Resume.find(session[:resume_id])
  end
  
  def new
    @resume = Resume.new
    template :form
  end
  
  def edit
    @resume = Resume.find(session[:resume_id])
    template :form
  end
  
  def create
    @resume = Resume.new(params[:resume])
    @resume.save!
    flash[:notice] = "Резюме опубликовано"
    session[:resume_id] = @resume.id
    redirect my_resumes_path
  end
  
  def update
    @resume = Resume.find(session[:resume_id])
    @resume.update_attributes!(params[:resume])
    flash[:notice] = "Резюме сохранено"
    redirect :show
  end
  
  def destroy
    @resume = Resume.destroy(session[:resume_id])
    flash[:notice] = 'Резюме удалено'
    log_out
  end
  
  def login  
  end 
  
  def log_in
    @resume = Resume.authenticate(params[:name], params[:password])   
    session[:resume_id] = @resume.id
    cookies[:resume_id] = { :value => @resume.id.to_s, :expires => 14.days.from_now, :path => '/' } if params[:remember_me] == 'on'
    redirect my_resumes_path
  rescue ArgumentError => e
    flash[:error] = e.message
    template :login
  end
  
  def log_out
    reset_session
    cookies.delete(:resume_id)
    redirect :login
  end

private
  def try_login_from_cookie
    return if session[:resume_id]
    session[:resume_id] = cookies[:resume_id].to_i if cookies[:resume_id] && Resume.exists?(cookies[:resume_id])
  end
end