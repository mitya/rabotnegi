class Admin::DashboardController < ApplicationController
  before_filter :admin_required
  ssl_required :show
  layout 'admin'

protected
  def admin_required
    self.admin = Admin.log_in('root', '0000') and return if Rails.env.test?
    authenticate_or_request_with_http_basic do |login, password|
      login == ADMIN_LOGIN && password == ADMIN_PASSWORD
    end
  end  
end
