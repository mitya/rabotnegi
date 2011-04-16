# coding: utf-8

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
      @resume = Resume.get!(params[:id])
      render :show
    else
      @resume = current_resume
      render :my
    end
  end

  def edit
    @resume = Resume.get!(session[:resume_id])
    render :form
  end

  def new
    @resume = Resume.new
    render :form
  end
  
  def create
    @resume = Resume.new(params[:resume])
    if @resume.save
      flash[:notice] = "Резюме опубликовано"
      session[:resume_id] = @resume.id
      redirect_to my_resume_path
    else
      render "form", :status => 422
    end
  end

  def update
    @resume = Resume.get!(session[:resume_id])
    if @resume.update_attributes(params[:resume])
      flash[:notice] = "Резюме сохранено"
      redirect_to my_resume_path
    else
      render "form", :status => 422
    end
  end
  
  def destroy
    @resume = Resume.destroy(session[:resume_id])
    flash[:notice] = 'Резюме удалено'
    log_out
  end
end
