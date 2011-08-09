# coding: utf-8

class Admin::UsersController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  model User

	def index
		@models = Model.paginate(params[:page], 30)
	end
end
