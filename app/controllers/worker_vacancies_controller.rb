# coding: utf-8

class WorkerVacanciesController < ApplicationController
  def create
    current_user!.favorite_vacancies << BSON::ObjectId(params[:id])
    current_user!.save!
    head :ok
  end  
  
  def destroy
    current_user!.favorite_vacancies.delete BSON::ObjectId(params[:id])
    current_user!.save!
    head :ok
  end
end
