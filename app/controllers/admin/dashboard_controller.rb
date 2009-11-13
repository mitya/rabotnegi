class Admin::DashboardController < ApplicationController
  before_filter :admin_required
  layout 'admin'
end
