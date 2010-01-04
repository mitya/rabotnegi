class ResumesController < ApplicationController
  before_filter :resume_required, :only => [:edit, :update, :destroy, :my]
  before_filter :resume_required, :only => :show, :if => proc { |c| !c.params[:id] }
  
  def index
    @resumes = Resume.
      search(params.slice(:city, :industry, :keywords, :salary)).
      scoped(:order => 'min_salary', :select => 'id, job_title, min_salary') if params[:city]
  end

  def show
    if params[:id]
      @resume = Resume.find(params[:id])
      render :show
    else
      @resume = current_resume
      render :my
    end
  end

  def edit
    @resume = Resume.find(session[:resume_id])
    render :form
  end

  def new
    @resume = Resume.new
    render :form
  end
  
  def create
    @resume = Resume.new(params[:resume])
    @resume.save!
    flash[:notice] = "Резюме опубликовано"
    session[:resume_id] = @resume.id
    redirect_to resume_path
  end
  
  def update
    @resume = Resume.find(session[:resume_id])
    @resume.update_attributes!(params[:resume])
    flash[:notice] = "Резюме сохранено"
    redirect_to resume_path
  end
  
  def destroy
    @resume = Resume.destroy(session[:resume_id])
    flash[:notice] = 'Резюме удалено'
    log_out
  end
end
