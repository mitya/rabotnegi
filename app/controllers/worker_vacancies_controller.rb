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
  
  def favorite
    @vacancies = current_user!.favorite_vacancy_objects
    render
  end
end
