class ResumesController < ApplicationController
  before_filter :resume_required, :only => [:edit, :update, :destroy, :my]
  
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
    render :form
  end
  
  def edit
    @resume = Resume.find(session[:resume_id])
    render :form
  end
  
  def create
    @resume = Resume.new(params[:resume])
    @resume.save!
    flash[:notice] = "Резюме опубликовано"
    session[:resume_id] = @resume.id
    redirect_to my_resumes_path
  end
  
  def update
    @resume = Resume.find(session[:resume_id])
    @resume.update_attributes!(params[:resume])
    flash[:notice] = "Резюме сохранено"
    redirect_to my_resumes_path
  end
  
  def destroy
    @resume = Resume.destroy(session[:resume_id])
    flash[:notice] = 'Резюме удалено'
    log_out
  end
end
